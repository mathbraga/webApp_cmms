import React, { Component } from "react";
import { Query } from 'react-apollo';
import gql from 'graphql-tag';
import { Switch, Route } from "react-router-dom";
import SpecsList from "./SpecsList";

class Contracts extends Component {
  render() {
    const fetchSpecs = gql`
      query SpecsQuery {
        allSpecs(orderBy: SPEC_SF_ASC) {
          nodes {
            specSf
            name
            category
            subcategory
          }
        }
      }
    `;
    return (
      <Query
        query={fetchSpecs}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              return null
            }
            const specs = data.allSpecs.nodes;

            return (
              <React.Fragment>
                <SpecsList
                  allItems={specs}
                />
              </React.Fragment>
            )
          }
        }</Query>
    )
  }
}

export default Contracts;