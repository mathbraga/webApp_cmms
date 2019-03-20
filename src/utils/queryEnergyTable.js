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
  if(this.state.chosenMeter === "199") {
    
    // Build array of all meters to query
    const allMeters = this.state.meters.map(meter => {
      return (100*parseInt(meter.medtype.N, 10) + parseInt(meter.med.N, 10)).toString();
    });
    
    // Query all meters in chosen period
    const resultAll = [];
    allMeters.forEach(meter => {
      this.state.dynamo.query({
        TableName: "EnergyTable",
        KeyConditionExpression: "med = :med AND aamm BETWEEN :aamm1 AND :aamm2",
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
        } else {
          data.Items.map(element => {
            Object.keys(element).map(key => {
              element[key] = Number(element[key].N);
            });
          });
          resultAll.push(data.Items);
        }
      })    
    })
    console.log(resultAll);
    this.setState({
      error: false,
      queryResponse: resultAll,
      showResult: true,
    });

  } else {
    
    // Query for only one meter
    this.state.dynamo.query({
      TableName: "EnergyTable",
      KeyConditionExpression: "med = :med AND aamm BETWEEN :aamm1 AND :aamm2",
      ExpressionAttributeValues: {
        ":med": {
          N: this.state.chosenMeter
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
        console.log(err);
        alert("There was an error. Please insert search parameters again.");
        this.setState({ error: true });
      } else {
        data.Items.map(element => {
          // Each 'element' is an item returned from the database table; map function loops through all items, changing the variable data
          Object.keys(element).map(key => {
            // Each key is an attribute of the database table; map function loops through all attributes, changing strings into numbers
            element[key] = Number(element[key].N); // Transforms each element[key].N (string) into Number
          });
        });
        console.log(data);
        this.setState({
          error: false,
          queryResponse: data,
          showResult: true
        });
      }
    });
  }
}
