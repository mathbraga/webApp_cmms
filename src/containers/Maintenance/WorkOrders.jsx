import React, { Component } from "react";
import { Route } from "react-router-dom";
import { Alert } from "reactstrap";
import WorkOrdersTable from "./WorkOrdersTable";
import { fakeWorkOrders } from "./fakeWorkOrders";
import { dbTables } from "../../aws";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import getWorkOrders from "../../utils/maintenance/getWorkOrders";
import { connect } from "react-redux";

class WorkOrders extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(this.props.session),
      tableName: dbTables.maintenance.tableName,
      workOrders: []
    }
    this.viewEntity = {
      id: event => {
        let workOrderId = event.target.name;
        this.props.history.push({
          pathname: `/manutencao/os/view/${workOrderId}`,
          state: {
            workOrderId: workOrderId
          }
        });
      },
      asset: event => {
        let assetId = event.target.name;
        this.props.history.push({
          pathname: `/ativos/view/${assetId}`,
          state: {
            assetId: assetId
          }
        });
      },
      local: event => {
        let localId = event.target.name;
        this.props.history.push({
          pathname: `/local/view/${localId}`,
          state: {
            localId: localId
          }
        });
      }
    }
  }

  componentDidMount(){
    getWorkOrders(this.state.dbObject, this.state.tableName)
    .then(workOrders => {
      console.log(workOrders);
      this.setState({
        workOrders: workOrders
      });
    })
    .catch(() => {
      console.log("Houve um problema ao baixar as ordens de serviço.");
    });
  }

  render() {
    return (
      <React.Fragment>

          <Route
            render={routerProps => (
              <WorkOrdersTable
                {...routerProps}
                tableConfig={fakeWorkOrders.tableConfig}
                items={this.state.workOrders}
                viewEntity={this.viewEntity}
              />
            )}
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
