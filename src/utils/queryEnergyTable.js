export function queryEnergyTable(state, tableName) {
  return new Promise((resolve, reject) => {
    // Transform form inputs into integers
    var month1 = state.initialDate.slice(5) + state.initialDate.slice(0, 2);
    var month2 = state.finalDate.slice(5) + state.finalDate.slice(0, 2);
    // if (state.oneMonth) {
    //   month2 = month1;
    // } else {
    //   month2 = state.finalDate.slice(5) + state.finalDate.slice(0, 2);
    // }

    // Check if consumer is 'all'
    if(state.chosenMeter === "199") {
      
      // Build array of all meters to query
      const allMeters = state.meters.map(meter => {
        return (100*parseInt(meter.medtype.N, 10) + parseInt(meter.med.N, 10)).toString();
      });
      
      // Query all meters in chosen period
      const resultAll = [];
      allMeters.forEach(meter => {
        state.dynamo.query({
          TableName: tableName,
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
            reject(Error("Failed to get the items."));
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
      resolve(resultAll);

    } else {
      
      // Query for only one meter
      state.dynamo.query({
        TableName: tableName,
        KeyConditionExpression: "med = :med AND aamm BETWEEN :aamm1 AND :aamm2",
        ExpressionAttributeValues: {
          ":med": {
            N: state.chosenMeter
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
          reject(Error("Failed to get the items."));
        } else {
          
          data.Items.map(element => {
            // Each 'element' is an item returned from the database table; map function loops through all items, changing the variable data
            Object.keys(element).map(key => {
              // Each key is an attribute of the database table; map function loops through all attributes, changing strings into numbers
              element[key] = Number(element[key].N); // Transforms each element[key].N (string) into Number
            });
          });
        resolve(data);
        }
      });
    }
  })
}
