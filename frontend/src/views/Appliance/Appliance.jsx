import React, { Component } from 'react';
import { compose } from 'redux';
import ItemView from '../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';
import props from './props';
import { withProps, withGraphQL, withQuery} from '../../hocs';
import paths from '../../paths';

// TO DO - These values will be passed as props
const image = require("../../assets/img/test/equipment_picture.jpg");
const imageStatus = 'Funcionando';

class Appliance extends Component {
  render() {
    const { data, graphQLVariables, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const descriptionItems = [
      { title: 'Equipamento / Sistema', description: finalData.name, boldTitle: true },
      { title: 'Código', description: finalData.assetSf, boldTitle: false },
      { title: 'Modelo', description: finalData.model, boldTitle: false },
      { title: 'Fabricante', description: finalData.manufacturer, boldTitle: false },
    ];
    return (
      <ItemView
        data={finalData}
        image={image}
        imageStatus={imageStatus}
        buttonName={"Editar"}
        buttonPath={paths.appliance.toUpdate + graphQLVariables.id.toString()}
        descriptionItems={descriptionItems}
        tabs={tabsGenerator(finalData)}
        {...rest}
      />
    );
  }
}

export default compose(
  withProps(props),
  withGraphQL,
  withQuery
)(Appliance);