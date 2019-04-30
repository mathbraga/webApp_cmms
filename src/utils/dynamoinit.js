import AWS from "aws-sdk";

export function dynamoInit() {
  AWS.config.region = "us-east-2";
  AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: "us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955"
  });
  var dynamo = new AWS.DynamoDB({
    apiVersion: "2012-08-10",
    endpoint: "https://dynamodb.us-east-2.amazonaws.com"
  });
  return dynamo;
}