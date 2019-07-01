export default function cleanDynamoQueryResponse(data){
  let answer = [];
  data.Items.forEach(item => {
    let obj = {};
    Object.keys(item).map(key => {
      switch(key){
        case "id" : obj[key] = item[key].N; break;
        case "impact" : obj[key] = item[key].BOOL; break;
        default : obj[key] = item[key].S;
      }
    });
    answer.push(obj);
  });
  return answer;
}