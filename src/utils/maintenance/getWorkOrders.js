export default function getWorkOrders(dbObject, tableName){
  return new Promise((resolve, reject) => {
    dbObject.scan({
      TableName: tableName
    }, (err, data) => {
      if(err){
        reject();
      } else {
        let answer = [];
        data.Items.map(item => {
          let obj = {};
          Object.keys(item).map(key => {
            if(key === "id") {
              obj[key] = item[key].N;
            } else {
              obj[key] = item[key].S;
            }
          });
          answer.push(obj);
        });
        resolve(answer);
      }
    })
  });
}