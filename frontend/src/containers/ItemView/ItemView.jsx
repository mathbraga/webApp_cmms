import React, { Component } from 'react';
import ItemViewUI from './ItemViewUI';

class ItemView extends Component {
  render() {
    return (
      <ItemViewUI
        {...this.props}
      />
    );
  }
}

export default ItemView;