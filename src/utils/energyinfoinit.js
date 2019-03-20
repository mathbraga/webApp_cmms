export function energyinfoinit(dbObject, tableName) {
  return new Promise((resolve, reject) => {
    dbObject.scan({TableName: tableName}, (err, data) => {
      if (err) {
        console.log(err);
        alert("There was an error in scan of table.");
        reject(Error("Failed to get the items."));
        } else {
          resolve(data.Items);
        }
      }
    );
  });
}