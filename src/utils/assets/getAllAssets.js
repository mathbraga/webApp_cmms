import cleanDynamoScanAssetsResponse from "./cleanDynamoScanAssetsResponse";

export default function getAllFacilities(dbObject, tableName){
  return new Promise((resolve, reject) => {
    dbObject.scan(
      {
        TableName: tableName,
      },
      (err, data) => {
        if(err) {
          reject();
        } else {
          resolve(cleanDynamoScanAssetsResponse(data));
        }
      }
    );
  });
}