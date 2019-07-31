import { serverAddress, allAssets } from '../../constants';

export default function getAllAssets(){
  return new Promise((resolve, reject) => {
    fetch(serverAddress + allAssets, {
      method: "GET"
    })
    .then(response => response.json())
    .then(data => resolve(data))
    .catch(() => {
      reject("Não foi possível baixar os ativos.");
    });
  });
}