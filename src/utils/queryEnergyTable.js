export default function queryEnergyTable(state, aamm1, aamm2) {
  return new Promise((resolve, reject) => {
  
  // Check if consumer is 'all'
  var allMeters = [];
  if (state.chosenMeter === "199") {
    // Build array of all meters to query
    allMeters = state.meters.map(meter => {
      return (
        100 * parseInt(meter.medtype.N, 10) +
        parseInt(meter.med.N, 10)
      ).toString();
    });
  } else {
    allMeters = [state.chosenMeter];
  }
  // Query all chosen meters
  let queryResponse = [];
  let arrayPromises = allMeters.map(meter => {
    return new Promise((resolve, reject) => {
      state.dynamo.query(
        {
          TableName: state.tableName,
          KeyConditionExpression:
            "med = :med AND aamm BETWEEN :aamm1 AND :aamm2",
          ExpressionAttributeValues: {
            ":med": {
              N: meter
            },
            ":aamm1": {
              N: aamm1
            },
            ":aamm2": {
              N: aamm2
            }
          }
        },
        (err, data) => {
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
  Promise.all(arrayPromises).then(() => {
    resolve(queryResponse);
  });

});


}
