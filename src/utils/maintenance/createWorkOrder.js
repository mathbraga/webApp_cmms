import dateToNum from "./dateToNum";

export default function createWorkOrder(state){
  return new Promise((resolve, reject) => {
    
    let {
      dbObject,
      tableName
    } = state;

    
    // BASIC ATTRIBUTES
    let id = Math.round(Math.random()*10000).toString();
    let creationDate = dateToNum(new Date());
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
    // status
    // multiTask
    // relatedWorkOrders
    // subTasks
    // log
    let asset = state.asset || "BL14-MEZ-043";
    let local = state.local || "Mezanino da SINFRA, sala do SEPLAG";

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
        },"reqName": {
          S: reqName
        },"asset": {
          S: asset
        },"local": {
          S: local
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