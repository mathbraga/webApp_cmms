import React, { Component } from 'react';
import { compose } from 'redux';
import ItemView from '../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';
import { withProps, withGraphQL, withQuery } from '../../hocs';
import props from './props';

const image = require("../../assets/img/test/equipment_picture.jpg");
const imageStatus = 'Em andamento';

class Spec extends Component {
  render() {
    const { data, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const descriptionItems = [
      { title: 'Serviço / Material', description: finalData.name, boldTitle: true },
      { title: 'Código', description: finalData.specSf, boldTitle: false },
      { title: 'Versão', description: finalData.version, boldTitle: false },
      { title: 'Disponibilidade', description: finalData.totalAvailable, boldTitle: false },
    ];
    return (
      <ItemView
        sectionName={'Especificação Técnica'}
        sectionDescription={'Especificacão técnica de um material/serviço'}
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
)(Spec);
