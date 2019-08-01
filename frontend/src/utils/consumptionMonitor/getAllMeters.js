import { serverAddress, cebMeters } from '../../constants';

export default function getAllMeters(meterType) {

  return new Promise((resolve, reject) => {
    
    fetch(serverAddress + cebMeters, {
      method: "GET"
    })
    .then(response => response.json())
    .then(data => resolve(data))
    .catch(() => {
      alert("There was an error in retrieving meters.");
      reject("Failed to get the items.");
    })
  });
}