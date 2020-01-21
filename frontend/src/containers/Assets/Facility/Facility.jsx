import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchGQL, fetchVariables } from './utils/dataFetchParameters';

class Facility extends Component {
  render() { 
    return (  );
  }
}
 
export default compose(
  withAccessToSession,
  withDataFetching(fetchGQL, fetchVariables(assetSf))
)(Facility);