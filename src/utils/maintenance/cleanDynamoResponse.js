import { dbTypes } from "./databaseAttrsAndTypes";

export default function cleanDynamoResponse(data){

  let items = [];

  if(data.Items === undefined){
    items.push(data.Item); // GET ITEM CASE (DB RESPONSE TYPE IS OBJECT)
  } else {
    items = data.Items; // QUERY OR SCAN CASE (DB RESPONSE TYPE IS ARRAY)
  }

  let cleanData = [];

  items.forEach(item => {
    let obj = {};
    Object.keys(item).map(key => {
      dbTypes.forEach(type => {
        if(item[key][type] !== undefined){
          if(type === "N"){
            obj[key] = Number(item[key][type]);
          } else {
            obj[key] = item[key][type]
          }
        }
      });
    });
    cleanData.push(obj);
  });
return cleanData;
}