import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { dbTables } from "../../aws";

class LocalView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.facility.tableName,
      message: "Carregando local...",
      local: false
    }
  }

  componentDidMount(){
    this.state.dbObject.getItem({
      TableName: this.state.tableName,
      Key: {
        "idlocal": {
          S: this.props.location.pathname.slice(12)
        }
      }
    }, (err, data) => {
      if(err) {
        this.setState({
          local: false,
          message: "Houve um erro no acesso ao banco de dados."
        });
      } else {
        console.log(data);
        if(Object.keys(data).length === 0){
          this.setState({
            local: false,
            message: "O local não existe no banco de dados."
          });
        } else {
          this.setState({
            local: data.Item
          });
        }
      }
    });
  }
  
  render() {
    return (
      <React.Fragment>
        {!this.state.local ? (
          <h3>{this.state.message}</h3>
        ) : (
          <h3>DISPLAY LOCAL: {this.state.local.idlocal.S}</h3>
        )}
      </React.Fragment>
    );
  }
}

export default LocalView;