// import buildChartData from './buildChartData';

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
  var allMeters = [];
  if (this.state.chosenMeter === "199") {
    // Build array of all meters to query
    allMeters = this.state.meters.map(meter => {
      return (
        100 * parseInt(meter.medtype.N, 10) +
        parseInt(meter.med.N, 10)
      ).toString();
    });
  } else {
    allMeters = [this.state.chosenMeter];
  }
  // Query all chosen meters
  let queryResponse = [];
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
        }, (err, data) => {
          if (err) {
            alert("There was an error. Please insert search parameters again.");
            reject();
          } else {
            // queryResponse.push([]);
            // data.Items.map(element => {
            //   queryResponse[queryResponse.length - 1].push(Object.assign(element));
            // });
            // RESPONSE IN FORMAT {aamm: {N: "1801"}}
            
            data.Items.map(element => {
              Object.keys(element).map(key => {
                element[key] = Number(element[key].N);
              });
            });
            queryResponse.push(data);
            
          }
          resolve();
        }
      );
    });
  });
  console.log(queryResponse);
  Promise.all(arrayPromises).then(() => {
    // buildChartData(queryResponse);
    this.setState({
      queryResponse: queryResponse,
      showResult: true,
      error: false
    });
  });
}