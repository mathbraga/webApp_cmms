import dateToNum from "./dateToNum";

export default function addImpact(state){
  return new Promise((resolve, reject) => {
    
    console.log('inside addImpact');

    
    let {
      dbObject,
      tableName,
      description,
      facilities,
      impactType,
      initialDate,
      finalDate
    } = state;

    let initialDateNum = dateToNum(initialDate);
    let finalDateNum = dateToNum(finalDate);

    // console.log('dates:');
    // console.log(initialDateNum);
    // console.log(finalDateNum);

    dbObject.putItem({
      TableName: tableName,
      Item: {
        "id": {
          N: Math.round(Math.random()*1000).toString()
        },
        "description": {
          S: description
        },
        "facilities": {
          S: facilities
        },
        "impactType": {
          S: impactType
        },
        "initialDate": {
          N: initialDateNum
        },
        "finalDate": {
          N: finalDateNum
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