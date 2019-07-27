export default function getAllMeters(meterType) {
  // Inputs:
  // dbObject (object): AWS DynamoDB configuration
  // tableNameMeters (string): name of table that contains meters information
  // tipomed (string): assumes the following cases:
  // - "1" for CEB (Energy)
  // - "2" for CAESB (Water)
  //
  // Output:
  // data.Items (array): contains all meters information in the database
  //
  // Purpose:
  // Provide all meters array to app components (e.g. dropdown in FormDates) and functions

  return new Promise((resolve, reject) => {
    
    fetch('http://localhost:3001/allmeters', {
      method: "GET"
    })
    .then(response => response.json())
    .then(data => resolve(data))
    .catch(() => {
      alert("There was an error in retrieving meters.");
      reject(Error("Failed to get the items."));
    })
  });
}