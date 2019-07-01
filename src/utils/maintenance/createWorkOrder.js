import dateToStr from "./dateToStr";

export default function createWorkOrder(state){
  return new Promise((resolve, reject) => {
    
    let {
      dbObject,
      tableName
    } = state;

    let filteredAssetsList = [];

    if(state.assetsList.length === 1 && state.assetsList[0] === ""){
      reject("É necessário selecionar um ativo para cadastrar a OS.");
    } else {
      filteredAssetsList = state.assetsList.filter(asset => (
        asset !== ""
      ));
    }
    
    // FORM-INDEPENDET ATTRIBUTES
    let id = Math.round(Math.random()*10000).toString();
    let creationDate = dateToStr(new Date());
    // creationTime
    // lastUpdate

    // ATTRIBUTES FROM REQUEST
    let selectedService = state.selectedService || "Troca de lâmpada da sala";
    let reqName = state.reqName || "Nikola Tesla";
    // reqEmail
    // reqPhone
    // conName
    // conEmail
    // conPhone
    // directions
    // description
    // details
    // files

    // OTHER ATTRIBUTES
    // situation
    // priority
    // assignedTo
    // category
    // sigad
    // requestingDepartment
    // messageToRequester
    // budget
    // initialDate
    // finalDate
    // progress
    // checked
    // executor
    // ans
    // multiTask
    // relatedWorkOrders
    // subTasks
    // log
    let status = "Pendente"
    // let asset = state.asset || "BL14-MEZ-043";
    let local = state.local || "BL14-MEZ-043";
    let impact = state.impact || false;

    dbObject.putItem({
      TableName: tableName,
      Item: {
        "id": {
          N: id
        },
        "creationDate": {
          S: creationDate
        },
        "selectedService": {
          S: selectedService
        },
        "reqName": {
          S: reqName
        },
        "status": {
          S: status
        },
        // "asset": {
        //   S: asset
        // },
        "local": {
          S: local
        },
        "impact": {
          BOOL: impact
        }
      }
    }, (err, data) => {
      if(err){
        reject("Houve um problema no cadastro da OS. Faça login ou tente novamente.");
      } else {
        
        let arrayPromises = filteredAssetsList.map(assetId => {
          return new Promise((resolve, reject) => {
            dbObject.putItem({
              TableName: "WOXASSET",
              Item: {
                "woId": {
                  N: id
                },
                "assetId": {
                  S: assetId
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
        });
        Promise.all(arrayPromises)
        .then(()=>resolve("OS CADASTRADA COM SUCESSO!"))
        .catch(()=>reject("HOUVE UM PROBLEMA."));
      }
    });
  });
}