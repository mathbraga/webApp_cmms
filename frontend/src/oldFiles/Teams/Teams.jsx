import React, { Component } from "react";
import { Query } from 'react-apollo';
import gql from 'graphql-tag';
import TeamsList from './TeamsList';
import { Switch, Route } from "react-router-dom";

class Teams extends Component {
  render() {
    const fetchTeams = gql`
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
    return (
      <Query
        query={fetchTeams}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              return null
            }
            const teams = data.allActiveTeams.nodes;

            return (
              <React.Fragment>
                <TeamsList
                  allItems={teams}
                />
              </React.Fragment>
            )
          }
        }</Query>
    )
  }
}

export default Teams;