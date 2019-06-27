import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { dbTables } from "../../aws";

class WorkOrderView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.maintenance.tableName,
    }
  }

  componentDidMount(){
    this.state.dbObject.getItem({
      TableName: this.state.tableName,
      Key: {
        "id": {
          N: this.props.location.state.workOrderId
        }
      }
    }, (err, woData) => {
      if(err) {
        console.log('error in view wo');
      } else {
        console.log(woData);
      }
    });
  }
  
  render() {


    return (
      <div>
        WO VIEW
      </div>
    );
  }
}

export default WorkOrderView;
