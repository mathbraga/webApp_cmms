import cleanDynamoResponse from "./cleanDynamoResponse";

export default function getASSETxWO(dbObject, tableName, assetId){
  return new Promise((resolve, reject) => {
    dbObject.query({
      TableName: tableName,
      IndexName: "assetId-woId-index",
      KeyConditionExpression: "assetId = :assetId",
      ExpressionAttributeValues: {
        ":assetId": {
          S: assetId
        }
      }
    }, (err, data) => {
      if(err){
        reject("NÃO FOI POSSÍVEL ENCONTRAR AS O.S.s DESTE ATIVO");
      } else {

        let cleanData = cleanDynamoResponse(data);
        resolve(cleanData);

      }
    });
  });
}