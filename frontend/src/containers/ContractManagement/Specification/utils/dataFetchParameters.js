import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($specId: Int!) {
    allBalances(condition: {specId: $specId}) {
      nodes {
        title
        supplySf
        supplyId
        specId
        qty
        fullPrice
        contractSf
        contractId
        consumed
        company
        blocked
        bidPrice
        available
      }
    }
    specBySpecId(specId: $specId) {
      version
      unit
      updatedAt
      subcategory
      spreadsheets
      specSf
      specId
      services
      qualification
      notes
      nodeId
      name
      materials
      lifespan
      isSubcont
      description
      criteria
      createdAt
      catser
      catmat
      category
      activities
    }
    allSpecOrders(condition: {specId: $specId}) {
      nodes {
        orderId
        status
        specId
        title
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };