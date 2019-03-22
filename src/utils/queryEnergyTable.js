export function queryEnergyTable() {
  // Transform form inputs into integers
  var month1 = this.state.initialDate.slice(5) + this.state.initialDate.slice(0, 2);
  var month2 = "";
  if (this.state.oneMonth) {
    month2 = month1;
  } else {
    month2 = this.state.finalDate.slice(5) + this.state.finalDate.slice(0, 2);
  }

  // Check if consumer is 'all'
  if (this.state.chosenMeter === "199") {
    // Build array of all meters to query
    var allMeters = this.state.meters.map(meter => {
      return (
        100 * parseInt(meter.medtype.N, 10) +
        parseInt(meter.med.N, 10)
      ).toString();
    });

    // Query all meters in chosen period
    var resultAll = [];
    let arrayPromises = allMeters.map(meter => {
      return new Promise((resolve, reject) => {
        this.state.dynamo.query(
          {
            TableName: this.state.tableName,
            KeyConditionExpression:
              "med = :med AND aamm BETWEEN :aamm1 AND :aamm2",
            ExpressionAttributeValues: {
              ":med": {
                N: meter
              },
              ":aamm1": {
                N: month1
              },
              ":aamm2": {
                N: month2
              }
            }
          },
          (err, data) => {
            if (err) {
              alert(
                "There was an error. Please insert search parameters again."
              );
            } else {
              data.Items.map(element => {
                Object.keys(element).map(key => {
                  element[key] = Number(element[key].N);
                });
              });
              resultAll.push(data);
            }
            resolve();
          }
        );
      });
    });
    // console.log(arrayPromises);
    Promise.all(arrayPromises).then(() => {
      this.setState({
        queryResponse: resultAll,
        showResult: true,
        error: false
      });
    });
  
  } else {
    
    // Query for only one meter
    let resultOne = [];
    let oneMeter = [this.this.state.chosenMeter];
    let arrayPromises = oneMeter.map(meter => {
      return new Promise((resolve, reject) => {
        this.state.dynamo.query(
          {
            TableName: this.state.tableName,
            KeyConditionExpression:
              "med = :med AND aamm BETWEEN :aamm1 AND :aamm2",
            ExpressionAttributeValues: {
              ":med": {
                N: meter
              },
              ":aamm1": {
                N: month1
              },
              ":aamm2": {
                N: month2
              }
            }
          },
          (err, data) => {
            if (err) {
              alert(
                "There was an error. Please insert search parameters again."
              );
            } else {
              data.Items.map(element => {
                Object.keys(element).map(key => {
                  element[key] = Number(element[key].N);
                });
              });
              resultOne.push(data);
            }
            resolve();
          }
        );
      });
    });
    // console.log(arrayPromises);
    Promise.all(arrayPromises).then(() => {
      this.setState({
        queryResponse: resultOne,
        showResult: true,
        error: false
      });
    });
  }
}
