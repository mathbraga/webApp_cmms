const fs = require('fs');
// const readline = require('readline');

export default function uploadFile(dbObject, tableName, file){
  return new Promise((resolve, reject) => {
    
    console.clear();
    console.log("inside uploadFile");
    tableName = tableName + "teste"; // Remover esta linha após os testes
    console.log("new tableName:");
    console.log(tableName);


    // const fileStream = fs.createReadStream(file);
    // console.log("fileStream");
    // console.log(fileStream);
    
    // const rl = readline.createInterface({
    // input: file,
    // crlfDelay: Infinity
    // });

    // Note: we use the crlfDelay option to recognize all instances of CR LF
    // ('\r\n') in input.txt as a single line break.

    // let requestItemsArr = [];

    // for (const line of rl) {
    //   // Each line in input.txt will be successively available here as `line`.
    //   console.log(`Line from file: ${line}`);
    //   let lineArr = line.split(";");
    //   requestItemsArr.push({
    //     PutRequest: {
    //       Item: {
    //         "med": {
    //           N:  lineArr[0]
    //         },
    //         "aamm": {
    //           N: lineArr[1],
    //         },
    //         "kwh": {
    //           N: lineArr[2]
    //         }
    //       }
    //     }
    //   });
    // }

    // Testa se o arquivo corresponde ao formato esperado (modelo CEB)
    
    // Elimina o cabeçalho

    // Lê o arquivo linha por linha, salvando cada linha como um objeto
    // O objeto resultante deve ser conforme modelo no Excel CEB-JSON, i.e.,
    // conforme atributos do banco de dados no DynamoDB
    

    // Constrói array de arrays com length máximo igual a 25
    // let maxLength = 25;
    // let paramsArr = [];
    // while(requestItemsArr.length > 0){
    //   paramsArr.push({RequestItems: {[tableName]: requestItemsArr.splice(0, maxLength)}})
    // }
    // console.log('paramsArr:');
    // console.log(paramsArr);

    // API batchWriteItem para escrever até 25 itens de uma vez
    // paramsArr.forEach(params => {
    //   dbObject.batchWriteItem(params, (err, data) =>{
    //     if(err){
    //       console.log("Houve um problema.");
    //       reject();
    //     } else {
    //       console.log("Inserção de dados OK.");
    //     }
    //   });
    // });
    // resolve();
  });
}