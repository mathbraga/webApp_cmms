import React, { Component } from "react";
import { Route } from "react-router-dom";
import WorkOrdersTable from "./WorkOrdersTable";
import WorkOrdersList from "./WorkOrdersList";
import { tableConfig } from "./WorkOrdersTableConfig";
import getAllWorkOrders from "../../utils/maintenance/getAllWorkOrders";
import { connect } from "react-redux";
import fetchDB from "../../utils/fetch/fetchDB";

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
    this.handleOSChange = this.handleOSChange.bind(this);
  }

  handleOSChange(dbResponse){
    this.setState({ workOrders: dbResponse });
  }

  componentDidMount(){
    fetchDB({
      query: `
        query WorkOrderQuery{
          allOrders {
            edges {
              node {
                category
                requestPerson
                status
                requestText
                orderId
                createdAt
                dateLimit
              }
            }
          }
        }
    `
    })
    .then(r => r.json())
    .then(rjson => this.handleOSChange(rjson))
    .catch(() => console.log("Houve um erro ao baixar as ordens de serviços."));
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
