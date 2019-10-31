import React, { Component } from "react";
import { Query } from 'react-apollo';
import gql from 'graphql-tag';
import PersonsList from './PersonList';
import { Switch, Route } from "react-router-dom";

class Persons extends Component {
  render() {
    const fetchAssets = gql`
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
    return (
      <Query
        query={fetchAssets}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              return null
            }
            const persons = data.allPeople.nodes;

            return (
              <React.Fragment>
                <PersonsList
                  allItems={persons}
                />
              </React.Fragment>
            )
          }
        }</Query>
    )
  }
}

export default Persons;