import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query MyQuery {
    queryResponse: allTeamData {
      nodes {
        teamId
        description
        memberCount
        members
        name
      }
    }
  }
`;

const fetchAppliancesVariables = {
};

export { fetchAppliancesGQL, fetchAppliancesVariables };