export default function removeEmpty(data){
  
  let noEmpty = [];

  data.forEach(element => {
    if(element.Items.length > 0){
      noEmpty.push(element.Items[0].med);
    }
  });

  return noEmpty;
}