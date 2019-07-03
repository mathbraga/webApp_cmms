export default function getWOxASSET(dbObject, tableName, workOrderId){
  return new Promise((resolve, reject) => {
    dbObject.query({
      TableName: tableName,
      KeyConditionExpression: "woId = :woId",
      ExpressionAttributeValues: {
        ":woId": {
          N: workOrderId
        }
      }
    }, (err, data) => {
      if(err){
        reject("NÃO FOI POSSÍVEL ENCONTRAR OS ATIVOS DESTA O.S.");
      } else {
        let assetsList = [];
        data.Items.forEach(asset => {
          assetsList.push(asset.assetId.S);
        });
        resolve(assetsList);
      }
    });
  });
}