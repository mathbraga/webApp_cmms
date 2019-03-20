export function energyinfoinit(dbObject, tableName) {
  return new Promise((resolve, reject) => {
    dbObject.query({
      TableName: tableName,
      KeyConditionExpression: "medtype = :medtype",
      ExpressionAttributeValues: {
        ":medtype": {
          N: "1"
        }
      }
    }, (err, data) => {
      if (err) {
        console.log(err);
        alert("There was an error in scan of table.");
        reject(Error("Failed to get the items."));
      } else {
        resolve(data.Items);
        console.log(data.Items);
      }
    });
  });
}