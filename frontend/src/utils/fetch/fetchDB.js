import { serverAddress, dbPath } from "../../constants";

export default function fetchDB(requestBody){
  return fetch(serverAddress + dbPath, {
    method: "POST",
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer ' + 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYXV0aCIsImV4cCI6MTU2NjU2NzQzNiwicGVyc29uX2lkIjoxLCJlbWFpbCI6Imh6bG9wZXNAc2VuYWRvLmxlZy5iciIsImlhdCI6MTU2NTk2MjYzNiwiYXVkIjoicG9zdGdyYXBoaWxlIiwiaXNzIjoicG9zdGdyYXBoaWxlIn0.Ppgfo9hgZ0kFhiTiVOoZJzSj2Z-f84uDLU-NumliJqY',
    },
    body: JSON.stringify(requestBody),
  })
}