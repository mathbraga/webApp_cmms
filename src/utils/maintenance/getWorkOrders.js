export default function getWorkOrders(dbObject, tableName){
  return new Promise((resolve, reject) => {
    dbObject.scan(tableName, (err, data) => {
      if(err){
        reject();
      } else {
        resolve(data.Items);
      }
    })
  });
}