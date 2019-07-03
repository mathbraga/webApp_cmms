// import cleanDynamoGetItemResponse from "./cleanDynamoGetItemResponse"

export default function getAsset(dbObject, tableName, assetId){
  return new Promise((resolve, reject) => {
    dbObject.getItem({
      TableName: tableName,
      Key: {
        "id": {
          S: assetId
        }
      }
    }, (err, data) => {
      if(err) {
        reject("Houve um erro no acesso ao banco de dados.");
      } else {

        if(Object.keys(data).length === 0){
         reject("O ativo não existe no banco de dados.");

        } else {

          resolve(data);

        }
      }
    });
  });
}