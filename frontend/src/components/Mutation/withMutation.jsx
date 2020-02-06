import React, { Component } from "react";
import { Mutation } from 'react-apollo';

export default function withMutation(GQL = null, variables = null) {
  return (
    function (WrappedComponent) {
      class WithMutation extends Component {
        render() {
          return (
            <Mutation
              mutation={this.props.mutationGQL || GQL}
              variables={this.props.mutationVariables || variables}
              onCompleted={ data => { console.log(data); this.props.history.push('/painel'); }}
            >
              {
                ({ loading, error, data, mutation }) => {
                  if (loading) return (<div>Carregando...</div>);
                  if (error) return (<div>Algo deu errado!</div>);
                  return (
                    <WrappedComponent
                      mutation={mutation}
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