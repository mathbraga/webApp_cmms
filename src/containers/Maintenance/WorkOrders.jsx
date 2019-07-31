import React, { Component } from "react";
import { Route } from "react-router-dom";
import WorkOrdersTable from "./WorkOrdersTable";
import { tableConfig } from "./WorkOrdersTableConfig";
import getAllWorkOrders from "../../utils/maintenance/getAllWorkOrders";
import { connect } from "react-redux";

class WorkOrders extends Component {
  constructor(props){
    super(props);
    this.state = {
      workOrders: []
    }
    this.viewEntity = {
      id: event => {
        let workOrderId = event.target.name;
        this.props.history.push(`/manutencao/os/view/${workOrderId}`);
      },
      asset: event => {
        let assetId = event.target.name;
        this.props.history.push(`/ativos/view/${assetId}`);
      }
    }
  }

  componentDidMount(){
    getAllWorkOrders()
    .then(workOrders => {
      console.log('workOrders:');
      console.log(workOrders);
      this.setState({
        workOrders: workOrders
      });
    })
    .catch(() => {
      console.log("Houve um problema ao baixar as ordens de serviços.");
    });
  }

  render() {
    return (
      <React.Fragment>
        <WorkOrdersTable
          tableConfig={tableConfig}
          items={this.state.workOrders}
          viewEntity={this.viewEntity}
        />
      </React.Fragment>
    );
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(WorkOrders);
