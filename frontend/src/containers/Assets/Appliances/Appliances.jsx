import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './dataFetchParameters';
import { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';
import AppliancesUI from './AppliancesUI';

const AppliancesWithData = withDataFetching(AppliancesUI, fetchAppliancesGQL, fetchAppliancesVariables);
const AppliancesWithDataAndSession = withAccessToSession(AppliancesWithData);

class Appliances extends Component {

  // TO DO: Put all the extra logic here.

  render() {
    return (
      <AppliancesWithDataAndSession />
    );
  }
}

export default Appliances;