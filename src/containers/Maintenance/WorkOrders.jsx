import React, { Component } from "react";
import { Route } from "react-router-dom";
import WorkOrdersTable from "./WorkOrdersTable";
import { tableConfig } from "./WorkOrdersTableConfig";
import { dbTables } from "../../aws";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import getAllWorkOrders from "../../utils/maintenance/getAllWorkOrders";
import { connect } from "react-redux";
import FileInput from "../../components/FileInputs/FileInput";

class WorkOrders extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(this.props.session),
      tableName: dbTables.workOrder.tableName,
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
    getAllWorkOrders(this.state.dbObject, this.state.tableName)
    .then(workOrders => {
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
                tableConfig={tableConfig}
                items={this.state.workOrders}
                viewEntity={this.viewEntity}
              />
            )}
          />

          {/* <FileInput
            readFile={dbTables.asset.readFile}
            buildParamsArr={dbTables.asset.buildParamsArr}
            tableName={"Ativo"}
            dbObject={this.state.dbObject}
          /> */}

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
