import AWS from "aws-sdk";

export default function initializeDynamoDB(userSession) {
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
  
  let dynamo = {};

  // In case there is no user logged in
  if(!userSession){

    AWS.config.region = "us-east-2";
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
      IdentityPoolId: "us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955"
    });

    dynamo = new AWS.DynamoDB({
      apiVersion: "2012-08-10",
      endpoint: "https://dynamodb.us-east-2.amazonaws.com"
    });

  // In case there is a user logged in
  } else {

    AWS.config.region = "us-east-2";
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
      IdentityPoolId: "us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955",
      Logins: {
          "cognito-idp.us-east-2.amazonaws.com/us-east-2_QljBw37l1": userSession.getIdToken().getJwtToken()
      },
      LoginId: userSession.getIdToken().payload.email
    });

    dynamo = new AWS.DynamoDB({
      apiVersion: "2012-08-10",
      endpoint: "https://dynamodb.us-east-2.amazonaws.com"
    });
  }

  return dynamo;

}