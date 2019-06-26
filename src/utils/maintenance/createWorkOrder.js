import dateToNum from "./dateToNum";

export default function createWorkOrder(state){
  return new Promise((resolve, reject) => {
    
    let {
      dbObject,
      tableName
    } = state;

    let creationDate = dateToNum(new Date());

    dbObject.putItem({
      TableName: tableName,
      Item: {
        "id": {
          N: Math.round(Math.random()*10000).toString()
        },
        "creationDate": {
          S: creationDate
        }
      }
    }, (err, data) => {
      if(err){
        reject();
      } else {
        resolve();
      }
    });
  });
}