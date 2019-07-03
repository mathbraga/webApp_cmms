import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import getAsset from "../../utils/maintenance/getAsset";
import getASSETxWO from "../../utils/maintenance/getASSETxWO";
import { dbTables } from "../../aws";
import { Button } from "reactstrap";

class AssetView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      asset: false,
      workOrdersList: []
    }
  }

  componentDidMount(){

    let assetId = this.props.location.pathname.slice(13);

    getAsset(this.state.dbObject, dbTables.asset.tableName, assetId)
    .then(asset => {
      console.log("Asset details:");
      console.log(asset);
      this.setState({
        asset: asset
      });
    })
    .catch(message => {
      console.log(message);
    });

    getASSETxWO(this.state.dbObject, dbTables.woxasset.tableName, assetId)
    .then(workOrdersList => {
      console.log("Work orders history of this asset:");
      console.log(workOrdersList);
      this.setState({
        workOrdersList: workOrdersList
      });
    })
    .catch(message => {
      console.log(message);
    });
  }
  
  render() {
    return (
      <React.Fragment>
        {!this.state.asset ? (
          <h3>Carregando ativo...</h3>
        ) : (
          <React.Fragment>
            <h3>ATIVO: {this.state.asset.id}</h3>
            <h4>OSs:
              {this.state.workOrdersList.map(wo => (
                <li
                  key={wo}
                >
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
