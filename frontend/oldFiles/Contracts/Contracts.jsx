import React, { Component } from "react";
import { Query } from 'react-apollo';
import gql from 'graphql-tag';
import { Switch, Route } from "react-router-dom";
import ContractsList from "./ContractsList";

class Contracts extends Component {
  render() {
    const fetchContracts = gql`
      query ContractsQuery {
        allContracts(orderBy: CONTRACT_SF_ASC) {
          nodes {
            company
            contractSf
            dateStart
            dateEnd
            status
            title
            url
          }
        }
      }
    `;
    return (
      <Query
        query={fetchContracts}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              return null
            }
            const contracts = data.allContracts.nodes;

            return (
              <React.Fragment>
                <ContractsList
                  allItems={contracts}
                />
              </React.Fragment>
            )
          }
        }</Query>
    )
  }
}

export default Contracts;