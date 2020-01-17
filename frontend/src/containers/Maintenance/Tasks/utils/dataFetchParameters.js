import gql from 'graphql-tag';

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

const fetchAppliancesVariables = {};

export { fetchAppliancesGQL, fetchAppliancesVariables };