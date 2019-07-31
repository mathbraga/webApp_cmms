export default function getAllWorkOrders(){
  return new Promise((resolve, reject) => {
    fetch('//localhost:3001/allwos', {
      method: 'GET'
    })
    .then(response => response.json())
    .then(data => resolve(data))
    .catch(()=>reject('Houve um problema em fetch'));
  });
}