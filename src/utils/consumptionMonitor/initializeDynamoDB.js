import AWS from "aws-sdk";

export default function initializeDynamoDB() {
  // Inputs:
  //
  // Output:
  // dynamo (object): contains configuration necessary for using AWS API to access DynamoDB tables
  //
  // Purpose:
  // Provide access to AWS DynamoDB

  // Minimal configuration to create a dbObject usable by AWS API:
  //  - region: Ohio
  //  - credentials: IdentityPool from Cognito
  // //    * Attention * The IdentityPool must have a role that allows un-authenticated read-only access to DynamoDB
  
  /////////////////////////////////////////////////////////////////////////////
  // AWS.config.region = "us-east-2";
  // AWS.config.credentials = new AWS.CognitoIdentityCredentials({
  //   IdentityPoolId: "us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955"
  // });

  // var dynamo = new AWS.DynamoDB({
  //   apiVersion: "2012-08-10",
  //   endpoint: "https://dynamodb.us-east-2.amazonaws.com"
  // });
  // return dynamo;
  /////////////////////////////////////////////////////////////////////////////

  AWS.config.region = "us-east-2";
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
      IdentityPoolId: "us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955",
      Logins: {
          "cognito-idp.us-east-2.amazonaws.com/us-east-2_QljBw37l1": window.sessionStorage.getItem('idToken')
      },
      LoginId: window.sessionStorage.getItem('email')
    });

  let dynamo = new AWS.DynamoDB({
    apiVersion: "2012-08-10",
    endpoint: "https://dynamodb.us-east-2.amazonaws.com"
  });
  
  return dynamo;

}