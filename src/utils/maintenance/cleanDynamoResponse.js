import formatDate from "./formatDate";

export default function cleanDynamoResponse(data){

  let dbAttrTypes = ["S", "N", "BOOL"];
  let items = [];
  let cleanData = [];

  if(data.Items === undefined){
    items.push(data.Item); // GET ITEM CASE (DB RESPONSE TYPE IS OBJECT)
  } else {
    items = data.Items; // QUERY OR SCAN CASE (DB RESPONSE TYPE IS ARRAY)
  }

  items.forEach(item => {
    let obj = {};
    Object.keys(item).map(key => {
      dbAttrTypes.forEach(type => {
        if(item[key][type] !== undefined){
          if(type === "N"){
            obj[key] = Number(item[key][type]);
          } else if(key === "creationDate"){
            obj[key] = formatDate(item[key][type]);
          } else {
            obj[key] = item[key][type];
          }
        }
      });
    });
    cleanData.push(obj);
  });
return cleanData;
}