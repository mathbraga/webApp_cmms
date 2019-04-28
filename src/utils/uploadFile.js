const fs = require('fs');
const path = require('path');
// const readline = require('readline');

export default function uploadFile(dbObject, tableName, file){
  return new Promise((resolve, reject) => {
    
    console.log("====== Inside uploadFile ======");
    tableName = tableName + "teste"; // Remover esta linha após os testes (usar tableName normal)

    let reader = new FileReader();
    reader.onload = function(x){
      let resultArr = x.target.result.replace(/(\r\n|\n|\r)/gm,"").split(';');
      console.log(resultArr);
      let requestItemsArr = [];
      requestItemsArr.push({
        PutRequest: {
          Item: {
            "med": {
              N: resultArr[3]
            },
            "aamm": {
              N: resultArr[4]
            },
            "kwh": {
              N: resultArr[5]
            }
          }
        }
      });
      console.log(requestItemsArr);
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
    }
    
    reader.readAsText(file);
    
    // let lineArr = line.split(";");
    // requestItemsArr.push({
    //   PutRequest: {
    //     Item: {
    //       "med": {
    //         N:  lineArr[0]
    //       },
    //       "aamm": {
    //         N: lineArr[1],
    //       },
    //       "kwh": {
    //         N: lineArr[2]
    //       }
    //     }
    //   }
    // });
    

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