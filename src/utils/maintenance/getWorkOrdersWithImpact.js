export default function getWorkOrdersWithImpact(dbObject, tableName){
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
            switch(key){
              case "id" : obj[key] = item[key].N; break;
              case "impact" : obj[key] = item[key].BOOL; break;
              default : obj[key] = item[key].S;
            }
          });
          if(obj.impact){
            answer.push(obj);
          }
        });
        resolve(answer);
      }
    })
  });
}