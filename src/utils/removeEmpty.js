export default function removeEmpty(data){
  // Input:
  // data (array): contains query response
  //
  // Output:
  // noEmpty (array): contains med of meters that actually have data for the query period
  //
  // Purpose:
  // Identify meters' med attributes that have data

  let noEmpty = [];

  data.forEach(element => {
    if(element.Items.length > 0){
      noEmpty.push(element.Items[0].med);
    }
  });

  return noEmpty;
}