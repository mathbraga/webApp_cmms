import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { dbTables } from "../../aws";

class AssetView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.asset.tableName,
    }
  }
  
  
  componentDidMount(){
    this.state.dbObject.getItem({
      TableName: this.state.tableName,
      Key: {
        "id": {
          S: this.props.location.state.assetId
        }
      }
    }, (err, assetData) => {
      if(err) {
        console.log('error in view asset');
      } else {
        console.log(assetData);
      }
    });
  }
  
  
  render() {


    return (
      <div>
        ASSET VIEW
      </div>
    );
  }
}

export default AssetView;
