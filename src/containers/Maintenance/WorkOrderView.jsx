import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import getWorkOrder from "../../utils/maintenance/getWorkOrder";
import getWOxASSET from "../../utils/maintenance/getWOxASSET";
import { dbTables } from "../../aws";
import { Button } from "reactstrap";

class WorkOrderView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      workOrder: false,
      assetsList: []
    }
  }

  componentDidMount(){

    let workOrderId = this.props.location.pathname.slice(20);

    getWorkOrder(this.state.dbObject, dbTables.workOrder.tableName, workOrderId)
    .then(workOrder => {
      console.log("Work order details:");
      console.log(workOrder);
      this.setState({
        workOrder: workOrder
      });
    })
    .catch(message => {
      console.log(message);
    });

    getWOxASSET(this.state.dbObject, dbTables.woxasset.tableName, workOrderId)
    .then(assetsList => {
      console.log("Assets assigned to this work order:");
      console.log(assetsList);
      this.setState({
        assetsList: assetsList
      });
    })
    .catch(message => {
      console.log(message);
    });
  }
  
  render() {
    return (
      <React.Fragment>
        {!this.state.workOrder ? (
          <h3>Carregando Ordem de Serviço...</h3>
        ) : (
          <React.Fragment>
            <h3>ORDEM DE SERVIÇO #{this.state.workOrder.id}</h3>
            <h4>ATIVOS:
              {this.state.assetsList.map(asset => (
                <li
                  key={asset.assetId}
                >
                  <Button
                    color="link"
                    onClick={()=>{this.props.history.push("/ativos/view/" + asset.assetId)}}
                  >{asset.assetId}
                  </Button>
                </li>
              ))}
            </h4>
          </React.Fragment>
        )}
     </React.Fragment>
    )
  }
}

export default WorkOrderView;
