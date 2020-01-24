import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchGQL } from './utils/dataFetchParameters';
import withGraphQLVariables from './withGraphQLVariables';
import { compose } from 'redux';
import ItemView from '../../ItemView/ItemView';
import tabsGenerator from './tabsGenerator';

const image = require("../../../assets/img/test/equipment_picture.jpg");
const imageStatus = 'Vigente';

class Contract extends Component {
  render() {
    console.log("Props: ", this.props);
    const { data, ...rest } = this.props;
    const treatedData = data.contractByContractSf;
    const descriptionItems = [
      { title: 'Objeto', description: treatedData.title, boldTitle: true },
      { title: 'Contrato nº', description: treatedData.contractSf, boldTitle: false },
      { title: 'Data Final', description: treatedData.dateEnd, boldTitle: false },
      { title: 'Empresa', description: treatedData.company, boldTitle: false },
    ];
    return (
      <ItemView
        data={data}
        image={image}
        imageStatus={imageStatus}
        descriptionItems={descriptionItems}
        tabs={tabsGenerator(data)}
        {...rest}
      />
    );
  }
}

export default compose(
  withGraphQLVariables,
  withAccessToSession,
  withDataFetching(fetchGQL, false)
)(Contract);