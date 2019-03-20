import AWS from "aws-sdk";

export function dynamoInit() {
  AWS.config.region = "us-east-2";
  AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: "us-east-2:03b9854f-67a5-4d77-819d-8ee654f8ad1b"
  });
  var dynamo = new AWS.DynamoDB({
    apiVersion: "2012-08-10",
    endpoint: "https://dynamodb.us-east-2.amazonaws.com"
  });
  return dynamo;
}