import gql from 'graphql-tag';

const fetchGQL = gql`
  query MyQuery($specId: Int!) {
    queryResponse: allSpecData(condition: {specId: $specId}) {
      nodes {
        specId
        specSf
        activities
        catmat
        catser
        comRef
        createdAt
        criteria
        description
        extRer
        isSubcont
        lifespan
        materials
        name
        notes
        qtyDecimals
        qualification
        services
        specCategoryId
        specCategoryText
        specSubcategoryId
        specSubcategoryText
        spreadsheets
        supplies
        unit
        updatedAt
        version
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };