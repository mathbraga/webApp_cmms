import React, { Component } from 'react';

export default function SelectLogic(WrappedComponent) {
  class SelectLogic extends Component {
    state = {
      selectedItems: [],
    }

    handleSelectItem(event) {
      console.log("Event: ", event.target);
    }

    render() {
      return (
        <WrappedComponent
          selectedItems={this.state.selectedItems}
          handleSelectItem={this.handleSelectItem}
          {...this.props}
        />
      );
    }
  }

  return SelectLogic;
}