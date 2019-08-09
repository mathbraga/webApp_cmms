import { serverAddress } from "../../constants";

export default function fetchDB(requestBody){
  return fetch(serverAddress, {
    method: "POST",
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: JSON.stringify(requestBody),
  })
}