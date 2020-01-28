import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query MyQuery {
    queryResponse: allPersonData {
      nodes {
        personId
        cellphone
        contractId
        cpf
        email
        isActive
        name
        personRole
        phone
        teams
      }
    }
  }
`;

const fetchAppliancesVariables = {
};

export { fetchAppliancesGQL, fetchAppliancesVariables };