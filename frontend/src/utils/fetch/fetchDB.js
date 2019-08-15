import { serverAddress, dbPath } from "../../constants";

export default function fetchDB(requestBody){
  
  const credentials = 'postgres:123456';//.toString('base64');
  
  return fetch(serverAddress + dbPath, {
    method: "POST",
    // credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Basic ' + credentials,
    },
    body: JSON.stringify(requestBody),
  })
}