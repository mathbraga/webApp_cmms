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
  if(this.state.consumer === "199") {
    
    // LISTA DE MEDIDORES
    const meters = [101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123];
    
    // QUERY TODO O PERÍODO (LOOP PARA CADA MEDIDOR)
    const resultAll = [];
    meters.forEach(meter => {
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
          resultAll.push(data);
        }
      })    
    })
    this.setState({
      error: false,
      queryResponse1: resultAll,
      showResult1: true,
    });
    //     }
    //   })
    // })



  } else {
    // Query EnergyTable and return results
    this.state.dynamo.query({
      TableName: "EnergyTable",
      KeyConditionExpression: "med = :med AND aamm BETWEEN :aamm1 AND :aamm2",
      ExpressionAttributeValues: {
        ":med": {
          N: this.state.consumer
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
          // error: false,
          queryResponse1: data,
          showResult1: true
        });
      }
    });

    // Query EnergyInfo and return results
    this.state.dynamo.query({
      TableName: "EnergyInfo",
      KeyConditionExpression: "med = :med",
      ExpressionAttributeValues: {
        ":med": {
          N: this.state.consumer
        }
      }
    }, (err, data) => {
      if (err) {
        console.log(err);
        alert("There was an error. Please insert search parameters again.");
        this.setState({ error: true });
      } else {
        console.log(data);
        this.setState({
          error: false,
          queryResponse2: data,
          showResult2: true
        });
      }
    });
  }
}
