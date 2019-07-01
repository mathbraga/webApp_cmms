import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import cleanDynamoGetItemResponse from "../../utils/maintenance/cleanDynamoGetItemResponse";
import { dbTables } from "../../aws";
import { Button } from "reactstrap";

class AssetView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.asset.tableName,
      message: "Carregando ativo...",
      asset: false,
      workOrdersList: []
    }
  }

  componentDidMount(){

    let assetId = this.props.location.pathname.slice(13);

    this.state.dbObject.getItem({
      TableName: this.state.tableName,
      Key: {
        "id": {
          S: assetId
        }
      }
    }, (err, data) => {
      if(err) {
        this.setState({
          asset: false,
          message: "Houve um erro no acesso ao banco de dados."
        });
      } else {
        if(Object.keys(data).length === 0){
          this.setState({
            asset: false,
            message: "O ativo não existe no banco de dados."
          });
        } else {
          this.state.dbObject.query({
            TableName: "WOXASSET",
            IndexName: "assetId-woId-index",
            KeyConditionExpression: "assetId = :assetId",
            ExpressionAttributeValues: {
              ":assetId": {
                S: assetId
              }
            }
          }, (wosError, wosData) => {
            if(wosError){
              console.log("NÃO FOI POSSÍVEL ENCONTRAR AS O.S.")
            } else {
              let workOrdersList = [];
              wosData.Items.forEach(wo => {
                workOrdersList.push(wo.woId.N);
              });
              this.setState({
                asset: data,
                workOrdersList: workOrdersList
              });
              console.log("RESULT:");
              console.log("Asset details:");
              console.log(this.state.asset);
              console.log("Work orders history of this asset:");
              console.log(this.state.workOrdersList);
            }
          });
        }
      }
    });
  }
  
  render() {
    return (
      <React.Fragment>
        {!this.state.asset ? (
          <h3>{this.state.message}</h3>
        ) : (
          <React.Fragment>
            <h3>ATIVO: {this.state.asset.id}</h3>
            <h4>OSs:
              {this.state.workOrdersList.map(wo => (
                <li>
                  <Button
                    color="link"
                    onClick={()=>{this.props.history.push("/manutencao/os/view/" + wo)}}
                  >{wo}
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

export default AssetView;
