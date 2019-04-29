export default function uploadFile(dbObject, tableName, file){
  return new Promise((resolve, reject) => {
    
    console.log("====== Inside uploadFile ======");
    
    // This line is only for testing purposes and should be removed later
    tableName = tableName + "teste";

    // Define reader and build array of items to be written in database table
    let reader = new FileReader();
    reader.onload = function(x){
      let resultArr = x.target.result.replace(/(\r\n|\n|\r)/gm,"").replace(",",".").split(';');
      console.log(resultArr);
      let requestItemsArr = [];
      requestItemsArr.push({
        PutRequest: {
          Item: {
            "med": {
              N: resultArr[2122] // Os índices são apenas para testar, não representam os atributos
            },
            "aamm": {
              N: resultArr[2123]
            },
            "kwh": {
              N: resultArr[2124]
            }
          }
        }
      });
      console.log("requestItemsArr:");
      console.log(requestItemsArr);

      // Build array of arrays with maximum length = 25 (AWS limit for batchWriteTtem API)
      let maxLength = 25;
      let paramsArr = [];
      while(requestItemsArr.length > 0){
        paramsArr.push({RequestItems: {[tableName]: requestItemsArr.splice(0, maxLength)}})
      }
      console.log('paramsArr:');
      console.log(paramsArr);

      // Use API batchWriteItem (write items in database table)
      let arrayPromises = paramsArr.map(params => {
        return new Promise((resolve, reject) => {
          dbObject.batchWriteItem(params, (err, data) =>{
            if(err){
              reject();
            } else {
              resolve();
            }
          });
        });
      });

      // After loop, Promise.all
      Promise.all(arrayPromises)
      .then(() => {
        resolve("Upload de dados concluído com sucesso!");
      })
      .catch(() => {
        reject("Houve um problema no upload do arquivo.")
      });
    }
    reader.readAsText(file);
  });
}