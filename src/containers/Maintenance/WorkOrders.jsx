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
        this.state.dbObject.getItem({
          TableName: dbTables.maintenance.tableName,
          Key: {
            "id": {
              N: workOrderId
            }
          }
        }, (err, woData) => {
          if(err) {
            console.log('error in view wo');
          } else {
            console.log(woData);
          }
        });
        this.props.history.push(`/manutencao/os/view/${workOrderId}`);
      },
      asset: event => {
        let assetId = event.target.name;
        console.log('inside viewAsset: ' + assetId);
        // this.state.dbObject.getItem({
        //   TableName: dbTables.asset.tableName,
        //   Key: {
        //     "id": {
        //       S: assetId
        //     }
        //   }
        // }, (err, assetData) => {
        //   if(err) {
        //     console.log('error in view asset');
        //   } else {
        //     console.log(assetData);
        //   }
        // });
        this.props.history.push(`/ativos/view/${assetId}`);
      },
      local: event => {
        let localId = event.target.name;
        this.state.dbObject.getItem({
          TableName: dbTables.facility.tableName,
          Key: {
            "idlocal": {
              S: localId
            }
          }
        }, (err, localData) => {
          if(err) {
            console.log('error in view local');
          } else {
            console.log(localData);
          }
        });
        this.props.history.push(`/local/view/${localId}`);
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
