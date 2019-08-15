import { serverAddress, dbPath } from "../../constants";

export default function fetchDB(requestBody){
  
  const credentials = 'postgres:123456';//.toString('base64');
  
  return fetch(serverAddress + dbPath, {
    method: "POST",
    // credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYXV0aCIsImV4cGlyZSI6MTU2NjUwNDcyNSwicGVyc29uX2lkIjoxLCJlbWFpbCI6InNwb3dlbGwwQG5vYWEuZ292IiwiaWF0IjoxNTY1ODk5OTI1LCJleHAiOjE1NjU5ODYzMjUsImF1ZCI6InBvc3RncmFwaGlsZSIsImlzcyI6InBvc3RncmFwaGlsZSJ9.QiQCxVeDwHyck3oB1Y8kidpMK0SZ7AJwAJLrAl6abR4',
    },
    body: JSON.stringify(requestBody),
  })
}