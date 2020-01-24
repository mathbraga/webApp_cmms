import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query ActiveTeamsQuery {
    allActiveTeams(orderBy: NAME_ASC) {
      nodes {
        teamId
        name
        description
        memberCount
      }
    }
  }
`;

const fetchAppliancesVariables = {
};

export { fetchAppliancesGQL, fetchAppliancesVariables };