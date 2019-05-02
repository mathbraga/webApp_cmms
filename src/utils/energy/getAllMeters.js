export default function getAllMeters(dbObject, tableNameMeters, tipomed) {
  // Inputs:
  // dbObject (object): AWS DynamoDB configuration
  // tableNameMeters (string): name of table that contains meters information
  // tipomed (string): assumes the following cases:
  // - "1" for CEB (Energy)
  // - "2" for CAESB (Water)
  //
  // Output:
  // data.Items (array): contains all meters information in the database
  //
  // Purpose:
  // Provide all meters array to app components (e.g. dropdown in FormDates) and functions

  return new Promise((resolve, reject) => {
    dbObject.query({
      TableName: tableNameMeters,
      KeyConditionExpression: "tipomed = :tipomed",
      ExpressionAttributeValues: {
        ":tipomed": {
          N: tipomed
        }
      }
    }, (err, data) => {
      if (err) {
        alert("There was an error in retrieving meters.");
        reject(Error("Failed to get the items."));
      } else {
        resolve(data.Items);
      }
    });
  });
}