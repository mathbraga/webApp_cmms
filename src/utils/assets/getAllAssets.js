export default function getAllAssets(dbObject, tableName){
  return new Promise((resolve, reject) => {
    fetch('http://localhost:3001/allassets', {
      method: "GET"
    })
    .then(response => response.json())
    .then(data => resolve(data))
    .catch(() => {
      alert("There was an error in retrieving all assets.");
      reject("Failed to get the assets.");
    });
  });
}