import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
      query WorkOrderQuery {
        allOrders(orderBy: ORDER_ID_ASC) {
          nodes {
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
              nodes {
                teamByTeamId {
                  teamId
                  name
                  isActive
                  description
                }
              }
            }
            orderAssetsByOrderId {
              nodes {
                assetByAssetId {
                  assetSf
                  name
                }
              }
            }
          }
        }
      }`;

const fetchAppliancesVariables = {};

export { fetchAppliancesGQL, fetchAppliancesVariables };