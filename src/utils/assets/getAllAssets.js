import cleanDynamoResponse from "../maintenance/cleanDynamoResponse";

export default function getAllAssets(dbObject, tableName){
  return new Promise((resolve, reject) => {
    dbObject.scan(
      {
        TableName: tableName,
      },
      (err, data) => {
        if(err) {
          reject();
        } else {
          resolve(cleanDynamoResponse(data));
        }
      }
    );
  });
}