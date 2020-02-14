import React, { Component } from 'react';
import { compose } from 'redux';
import ItemView from '../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';
import props from './props';
import { withProps, withGraphQL, withQuery } from '../../hocs';

const image = require("../../assets/img/test/equipment_picture.jpg");
const imageStatus = 'Em andamento';

class Task extends Component {
  render() {
    const { data, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const descriptionItems = [
      { title: 'Serviço', description: finalData.title, boldTitle: true },
      { title: 'Ordem de Serviço nº', description: finalData.taskId.toString().padStart(4, "0"), boldTitle: false },
      { title: 'Local', description: finalData.place, boldTitle: false },
      { title: 'Categoria', description: finalData.taskCategoryText, boldTitle: false },
    ];
    return (
      <ItemView
        data={finalData}
        image={image}
        imageStatus={imageStatus}
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
)(Task);