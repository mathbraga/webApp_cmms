export default function uploadFile(dbObject, tableName/*, file*/){
  return new Promise((resolve, reject) => {
    
    console.log();
    console.log("inside uploadFile");
    // Testa se o arquivo corresponde ao formato esperado (modelo CEB)
    let N = 1000; // Elimina o cabeçalho

    // Lê o arquivo linha por linha, salvando cada linha como um objeto
    // O objeto resultante deve ser conforme modelo no Excel CEB-JSON, i.e.,
    // conforme atributos do banco de dados no DynamoDB
    let requestItemsArr = [];
    for(let i = 0; i < N - 1; i++){
      requestItemsArr.push(0);
    }  

    // Constrói array de arrays com length máximo igual a 25
    let maxLength = 25;
    let paramsArr = [];
    while(requestItemsArr.length > 0){
      paramsArr.push({RequestItems: {[tableName]: requestItemsArr.splice(0, maxLength)}})
    }
    console.log('paramsArr:');
    console.log(paramsArr);

    // API batchWriteItem para escrever até 25 itens de uma vez
    paramsArr.forEach(params => {
      dbObject.batchWriteItem(params, (err, data) =>{
        if(err){
          console.log("Houve um problema.");
          reject();
        } else {
          console.log("Inserção de dados OK.");
        }
      });
    });
    resolve();
  });
}