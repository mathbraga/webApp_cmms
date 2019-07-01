import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { dbTables } from "../../aws";

class AssetView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.asset.tableName,
      message: "Carregando ativo...",
      asset: false
    }
  }

  componentDidMount(){
    this.state.dbObject.getItem({
      TableName: this.state.tableName,
      Key: {
        "id": {
          S: this.props.location.pathname.slice(13)
        }
      }
    }, (err, data) => {
      if(err) {
        this.setState({
          asset: false,
          message: "Houve um erro no acesso ao banco de dados."
        });
      } else {
        console.log(data);
        if(Object.keys(data).length === 0){
          this.setState({
            asset: false,
            message: "O ativo não existe no banco de dados."
          });
        } else {
          this.setState({
            asset: data.Item
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
          <h3>DISPLAY ATIVO: {this.state.asset.id.S}</h3>
        )}
      </React.Fragment>
    );
  }
}

export default AssetView;
