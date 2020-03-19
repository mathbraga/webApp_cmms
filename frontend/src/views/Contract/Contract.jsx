import React, { Component } from 'react';
import { compose } from 'redux';
import ItemView from '../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';
import { withProps, withGraphQL, withQuery } from '../../hocs';
import props from './props';

const image = require("../../assets/img/test/equipment_picture.jpg");
const imageStatus = 'Vigente';

class Contract extends Component {
  render() {
    const { data, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const descriptionItems = [
      { title: 'Objeto', description: finalData.title, boldTitle: true },
      { title: 'Contrato nº', description: finalData.contractSf, boldTitle: false },
      { title: 'Data Final', description: finalData.dateEnd, boldTitle: false },
      { title: 'Empresa', description: finalData.company, boldTitle: false },
    ];
    return (
      <ItemView
        data={finalData}
        image={image}
        imageStatus={imageStatus}
        descriptionItems={descriptionItems}
        tabs={tabsGenerator(finalData)}
        buttonName={"Editar"}
        {...rest}
      />
    );
  }
}

export default compose(
  withProps(props),
  withGraphQL,
  withQuery
)(Contract);