import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { qQuery, qConfig } from './graphql';
import MultipleSelect from '../../components/MultipleSelect';

class AssetSelect extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { config, selected, addItem, removeItem, handleQty } = this.props;

    return (
      <MultipleSelect
        config={config}
        selected={selected}
        addItem={addItem}
        removeItem={removeItem}
        handleQty={handleQty}
      />
    );
  }
}

export default graphql(qQuery, qConfig)(AssetSelect);
