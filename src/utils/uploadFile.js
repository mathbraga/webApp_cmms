export default function uploadFile(dbObject, tableName, file){
  return new Promise((resolve, reject) => {
    
    console.log("====== Inside uploadFile ======");
    
    // This line is only for testing purposes and should be removed later
    tableName = tableName + "teste";

    // Define reader and build array of items to be written in database table
    let reader = new FileReader();
    reader.onload = function(x){
      let resultArr = x.target.result.trim().replace(/(\r\n|\n|\r)/gm,"").replace(",",".").split(';');
      console.log("resultArr");
      console.log(resultArr);

      // Discard header, split big array into many arrays (each small array represents a meter in CEB csv file)
      let numColumns = 102;
      let noHeader = resultArr.splice(numColumns);
      noHeader.splice(noHeader.length - 1);

      console.log('noHeader:');
      console.log(noHeader);

      let lines = [];
      while(noHeader.length > 0){
        lines.push(noHeader.splice(0, numColumns));
      }

      let requestItemsArr = [];
      lines.forEach(line => {
        requestItemsArr.push({
          PutRequest: {
            Item: {
              "med": {
                N: line[0]
              },
              "aamm": {
                N: line[12].slice(2)
              },
              "kwh": {
                N: line[1]
              }
            }
          }
        });
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