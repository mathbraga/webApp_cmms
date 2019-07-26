export default function getWorkOrder(workOrderId){
  return new Promise((resolve, reject) => {
    fetch('//localhost:3001/getwo?id=' + workOrderId, {
      method: 'GET'
    })
    .then(response => response.json())
    .then(data => resolve(data))
    .catch(()=>reject('Houve um problema em fetch'));
  });
}