import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchGQL } from './utils/dataFetchParameters';
import withGraphQLVariables from './withGraphQLVariables';
import { compose } from 'redux';

class Facility extends Component {
  render() {
    return (
      <h1>Hi</h1>
    );
  }
}

export default compose(
  withGraphQLVariables,
  withAccessToSession,
  withDataFetching(fetchGQL, false)
)(Facility);