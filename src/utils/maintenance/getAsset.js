export default function getAsset(assetId){
  return new Promise((resolve, reject) => {
    fetch('//localhost:3001/getasset?id=' + assetId, {
      method: 'GET'
    })
    .then(response => response.json())
    .then(data => resolve(data))
    .catch(()=>reject('Houve um problema em fetch'));
  });
}