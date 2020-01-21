import React, { Component } from "react";
import { Query } from 'react-apollo';

export default function withDataFetching(graphQLString, graphQLVariables) {
  return (
    function (WrappedComponent) {
      class WithDataFetching extends Component {
        render() {
          return (
            <Query
              query={graphQLString}
              variables={graphQLVariables || this.props.customGraphQLVariables}
            >
              {
                ({ loading, error, data }) => {
                  if (loading) return (<div>Carregando...</div>);
                  if (error) return (<div>Algo deu errado!</div>);
                  return (
                    <WrappedComponent
                      data={data}
                      {...this.props}
                    />
                  );
                }
              }
            </Query>
          );
        }
      }

      // Add display name for debugging.
      WithDataFetching.displayName = `WithDataFetching(${WrappedComponent.displayName ||
        WrappedComponent.name ||
        "Component"})`;

      return WithDataFetching;
    }
  );
}