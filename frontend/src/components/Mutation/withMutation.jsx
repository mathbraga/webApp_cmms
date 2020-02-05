import React, { Component } from "react";
import { Mutation } from 'react-apollo';

export default function withMutation(graphQLString, graphQLVariables) {
  return (
    function (WrappedComponent) {
      class WithMutation extends Component {
        render() {
          return (
            <Mutation
              mutation={graphQLString}
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
            </Mutation>
          );
        }
      }

      // Add display name for debugging.
      WithMutation.displayName = `WithMutation(${WrappedComponent.displayName ||
        WrappedComponent.name ||
        "Component"})`;

      return WithMutation;
    }
  );
}