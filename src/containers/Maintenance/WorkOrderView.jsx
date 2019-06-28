import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { dbTables } from "../../aws";

class WorkOrderView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.maintenance.tableName,
      error: false,
      workOrder: false
    }
  }

  componentDidMount(){
    this.state.dbObject.getItem({
      TableName: this.state.tableName,
      Key: {
        "id": {
          N: this.props.location.pathname.slice(20)
        }
      }
    }, (err, woData) => {
      if(err) {
        console.log('error in view wo');
        this.setState({
          error: true
        });
      } else {
        console.log(woData);
        if(Object.keys(woData).length === 0){
          this.setState({
            error: true
          });
        } else {
          this.setState({
            workOrder: woData.Item
          });
        }
      }
    });
  }
  
  render() {
    return (
      <React.Fragment>
        {this.state.error ? (
          <h3>OS NÃO ENCONTRADA</h3>
        ) : (
          <React.Fragment>
            {this.state.workOrder ? (
            <h3>DISPLAY OS: {this.state.workOrder.id.N}</h3>
          ) : (
            <h3>Carregando OS</h3>
          )}
          </React.Fragment>
        )}
      </React.Fragment>
    );
  }
}

export default WorkOrderView;
