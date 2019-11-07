import React, { Component } from "react";
import { Route } from "react-router-dom";
import WorkOrdersTable from "./WorkOrdersTable";
import WorkOrdersList from "./WorkOrdersList";
import { tableConfig } from "./WorkOrdersTableConfig";
import getAllWorkOrders from "../../utils/maintenance/getAllWorkOrders";
import { connect } from "react-redux";
import fetchDB from "../../utils/fetch/fetchDB";
import { Query } from 'react-apollo';
import gql from 'graphql-tag';

class WorkOrders extends Component {
  constructor(props) {
    super(props);
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

  render() {
    const osQuery = gql`
      query WorkOrderQuery {
        allOrders(orderBy: ORDER_ID_ASC) {
          edges {
            node {
              category
              createdBy
              status
              title
              description
              orderId
              createdAt
              dateLimit
              place
              priority
              contractId
              contractByContractId {
                contractSf
                contractId
                company
              }
              orderTeamsByOrderId {
                edges {
                  node {
                    teamByTeamId {
                      teamId
                      name
                      isActive
                      description
                    }
                  }
                }
              }
              orderAssetsByOrderId {
                edges {
                  node {
                    assetByAssetId {
                      assetSf
                      name
                    }
                  }
                }
              }
            }
          }
        }
      }`;

    return (
      <Query query={osQuery}>{
        ({ loading, error, data }) => {
          if (loading) return null
          if (error) {
            console.log("Erro ao tentar baixar as OS!");
            return null
          }
          const workOrders = data;

          return (
            <React.Fragment>
              {workOrders.allOrders.edges.length !== 0 &&
                <WorkOrdersList
                  allItems={workOrders}
                  viewEntity={this.viewEntity}
                />
              }
            </React.Fragment>
          )
        }
      }</Query>
    );
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(WorkOrders);
