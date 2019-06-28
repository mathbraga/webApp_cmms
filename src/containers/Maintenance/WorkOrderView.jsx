import React, { Component } from "react";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { dbTables } from "../../aws";

class WorkOrderView extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(false),
      tableName: dbTables.workOrder.tableName,
      message: "Carregando ordem de serviço...",
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
    }, (err, data) => {
      if(err) {
        this.setState({
          workOrder: false,
          message: "Houve um erro no acesso ao banco de dados."
        });
      } else {
        console.log(data);
        if(Object.keys(data).length === 0){
          this.setState({
            workOrder: false,
            message: "A OS não existe no banco de dados."
          });
        } else {
          this.setState({
            workOrder: data.Item
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
          <h3>DISPLAY OS: {this.state.workOrder.id.N}</h3>
        )}
      </React.Fragment>
    );
  }
}

export default WorkOrderView;
