export default function queryTable(dbObject, tableName, chosenMeter, meters, aamm1, aamm2) {
  return new Promise((resolve, reject) => {
    // Check if consumer is 'all'
    var allMeters = [];
    if (chosenMeter === "199") {
      // Build array of all meters to query
      allMeters = meters.map(meter => {
        return (
          100 * parseInt(meter.tipomed.N, 10) +
          parseInt(meter.med.N, 10)
        ).toString();
      });
    } else {
      allMeters = [chosenMeter];
    }
    // Query all chosen meters
    let queryResponse = [];
    let arrayPromises = allMeters.map(meter => {
      return new Promise((resolve, reject) => {
        dbObject.query(
          {
            TableName: tableName,
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
              data.Items.forEach(element => {
                Object.keys(element).forEach(key => {
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
