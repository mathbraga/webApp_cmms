import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import cleanDynamoGetItemResponse from "../../utils/maintenance/cleanDynamoGetItemResponse";
import { dbTables } from "../../aws";
import { Button } from "reactstrap";

class WorkOrderView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.workOrder.tableName,
      message: "Carregando ordem de serviço...",
      workOrder: false,
      assetsList: []
    }
  }

  componentDidMount(){

    let workOrderId = this.props.location.pathname.slice(20);

    this.state.dbObject.getItem({
      TableName: this.state.tableName,
      Key: {
        "id": {
          N: workOrderId
        }
      }
    }, (err, data) => {
      if(err) {
        this.setState({
          workOrder: false,
          message: "Houve um erro no acesso ao banco de dados."
        });
      } else {
        if(Object.keys(data).length === 0){
          this.setState({
            workOrder: false,
            message: "A OS não existe no banco de dados."
          });
        } else {
          this.state.dbObject.query({
            TableName: "WOXASSET",
            KeyConditionExpression: "woId = :woId",
            ExpressionAttributeValues: {
              ":woId": {
                N: workOrderId
              }
            }
          }, (assetsError, assetsData) => {
            if(assetsError){
              console.log("NÃO FOI POSSÍVEL ENCONTRAR OS ATIVOS DESTA O.S.")
            } else {
              let assetsList = [];
              assetsData.Items.forEach(asset => {
                assetsList.push(asset.assetId.S);
              });
              this.setState({
                workOrder: cleanDynamoGetItemResponse(data),
                assetsList: assetsList
              });
              console.log("RESULT:");
              console.log("Word order details:");
              console.log(this.state.workOrder);
              console.log("Assets assigned to this work order:");
              console.log(this.state.assetsList);
            }
          });
        }
      }
    });
  }
  
  render() {
    return (
      <React.Fragment>
        {!this.state.workOrder ? (
          <h3>{this.state.message}</h3>
        ) : (
          <React.Fragment>
            <h3>ORDEM DE SERVIÇO #{this.state.workOrder.id}</h3>
            <h4>ATIVOS:
              {this.state.assetsList.map(asset => (
                <li
                  key={asset}
                >
                  <Button
                    color="link"
                    onClick={()=>{this.props.history.push("/ativos/view/" + asset)}}
                  >{asset}
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
