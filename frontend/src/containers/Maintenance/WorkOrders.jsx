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
    this.handleAssetsChange = this.handleAssetsChange.bind(this);
  }

  handleAssetsChange(dbResponse){
    this.setState({ workOrders: dbResponse });
  }

  componentDidMount(){
    fetchDB({
      query: `
        query WorkOrderQuery{
          allWorkOrders {
            edges {
              node {
                categoria
                solicNome
                status1
                descricao
                id
                dataCriacao
                dataPrazo
              }
            }
          }
        }
    `
    })
    .then(r => r.json())
    .then(rjson => this.handleAssetsChange(rjson))
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
