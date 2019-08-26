import React, { Component } from "react";
import { Route } from "react-router-dom";
import WorkOrdersTable from "./WorkOrdersTable";
import WorkOrdersList from "./WorkOrdersList";
import { tableConfig } from "./WorkOrdersTableConfig";
import getAllWorkOrders from "../../utils/maintenance/getAllWorkOrders";
import { connect } from "react-redux";
import { IncomingMessage } from "http";

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
    console.log(process.env);
    fetch(process.env.REACT_APP_SERVER_URL + '/logout', {
      method: 'GET',
      credentials: 'include',
    })

    .then(r => r.json())
    .then(rjson => console.log(rjson))
    .catch(()=>console.log('Erro no fecth em Dashboard'));
  }

  render() {
    return (
      <React.Fragment>
        {this.state.workOrders.length !== 0 &&
        <WorkOrdersList
          allItems={this.state.workOrders}
          viewEntity={this.viewEntity}
        />
        }
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
