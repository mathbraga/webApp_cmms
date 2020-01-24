import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($orderId: Int!) {
    orderByOrderId(orderId: $orderId) {
      category
      status
      priority
      orderId
      place
      departmentId
      progress
      contractId
      dateEnd
      dateLimit
      dateStart
      parent
      contactEmail
      contactPhone
      createdBy
      description
      title
      orderByParent {
        title
        orderId
        priority
        status
        dateStart
        dateLimit
      }
      createdAt
      orderAssetsByOrderId {
        nodes {
          assetByAssetId {
            assetSf
            name
            category
          }
        }
      }
    }
    allOrderSuppliesDetails(condition: {orderId: $orderId}) {
      nodes {
        supplySf
        name
        qty
        unit
        bidPrice
        total
        specId
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };