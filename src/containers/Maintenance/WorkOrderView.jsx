import React, { Component } from "react";
import getWorkOrder from "../../utils/maintenance/getWorkOrder";
import { Button } from "reactstrap";

class WorkOrderView extends Component {
  constructor(props){
    super(props);
    this.state = {
      workOrder: false,
    }
  }

  componentDidMount(){

    let workOrderId = this.props.location.pathname.slice(20);

    getWorkOrder(workOrderId)
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
  }
  
  render() {
    return (
      <React.Fragment>
        {/* {!this.state.workOrder ? (
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
        )} */}
     </React.Fragment>
    )
  }
}

export default WorkOrderView;
