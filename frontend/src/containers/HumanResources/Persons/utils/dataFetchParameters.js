import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
query PersonsQuery {
  allPeople(orderBy: NAME_ASC) {
    nodes {
      cpf
      email
      name
      phone
    }
  }
}
`;

const fetchAppliancesVariables = {
};

export { fetchAppliancesGQL, fetchAppliancesVariables };