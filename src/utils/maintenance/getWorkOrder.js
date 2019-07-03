import cleanDynamoResponse from "./cleanDynamoResponse"

export default function getWorkOrder(dbObject, tableName, workOrderId){
  return new Promise((resolve, reject) => {
    dbObject.getItem({
      TableName: tableName,
      Key: {
        "id": {
          N: workOrderId
        }
      }
    }, (err, data) => {
      if(err) {
        reject("Houve um erro no acesso ao banco de dados.");
      } else {

        if(Object.keys(data).length === 0){
         reject("A OS não existe no banco de dados.");

        } else {

          resolve(cleanDynamoResponse(data));
        }
      }
    });
  });
}