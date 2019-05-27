import {
  CognitoUserPool,
  CognitoUserAttribute
} from "amazon-cognito-identity-js";

export default function signUpCognito(email, password1, password2){
  return new Promise((resolve, reject) => {

    console.log("Inside signUpCognito");
    
    if(password1 === password2){
      
      let poolData = {
        UserPoolId : "us-east-2_QljBw37l1",
        ClientId : "25k8mc8m13pgpaihrhvcuvonpq"
      };
  
      let userPool = new CognitoUserPool(poolData);
  
      const attributeList = [
        new CognitoUserAttribute({
          Name: "email",
          Value: email,
        })
      ];
        
      userPool.signUp(email, password1, attributeList, null, (err, result) => {
        if (err) {
          console.log(err);
          reject();
        } else {
          resolve(result.user);
        }
      });
    } else {
      reject();
    }
  })
}