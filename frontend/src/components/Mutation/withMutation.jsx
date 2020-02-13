import React, { Component } from "react";
import { Mutation } from 'react-apollo';

export default function withMutation(WrappedComponent) {
  class WithMutation extends Component {
    render() {
      return (
        <Mutation
          mutation={this.props.mutationGQL}
          mutate={this.props.handleFunctions.handleSubmit}
          variables={this.props.formVariables}
          onCompleted={ data => { console.log(data); this.props.history.push('/painel'); }}
        >
          {
            ( mutate, { loading, error, data } ) => {
              if (loading) return (<div>Carregando...</div>);
              if (error) return (<div>Algo deu errado!</div>);
              return (
                <WrappedComponent
                  mutate={mutate}
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