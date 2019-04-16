import AWS from "aws-sdk";

export default function userPoolInit(){
  
  AWS.config.region = "us-east-2";
  AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: "us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955"
  });

  // let userPool = new AWS.CognitoIdentity.CognitoUserPool({
  //   UserPoolId : "us-east-2_b0jTWet7h",
  //   ClientId : "2ej9a4efc0kbqmnus5r0naj6to"
  // });
  console.log("AWS");
  console.log(AWS);
  // return userPool;
}