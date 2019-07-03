import cleanDynamoResponse from "./cleanDynamoResponse";

export default function getAllWorkOrders(dbObject, tableName){
  return new Promise((resolve, reject) => {
    dbObject.scan({
      TableName: tableName
    }, (err, data) => {
      if(err){
        reject();
      } else {
        resolve(cleanDynamoResponse(data));
      }
    })
  });
}