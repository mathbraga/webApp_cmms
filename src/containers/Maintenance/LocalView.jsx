import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { dbTables } from "../../aws";

class LocalView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.facility.tableName,
    }
  }

  componentDidMount(){
    this.state.dbObject.getItem({
      TableName: this.state.tableName,
      Key: {
        "idlocal": {
          S: this.props.location.state.localId
        }
      }
    }, (err, localData) => {
      if(err) {
        console.log('error in view local');
      } else {
        console.log(localData);
      }
    });
  }
  
  render() {


    return (
      <div>
        LOCAL VIEW
      </div>
    );
  }
}

export default LocalView;
