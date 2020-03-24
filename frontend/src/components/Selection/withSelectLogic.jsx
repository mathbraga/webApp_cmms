import React, { Component } from 'react';

export default function withSelectLogic(WrappedComponent) {
  class SelectLogic extends Component {
    state = {
      selectedItems: {},
    }

    handleSelectItem = (itemId) => () => {
      this.setState((prevState) =>
        {
          console.log("Here: ", itemId, !prevState.selectedItems[itemId]);
          return ({
            selectedItems: { ...prevState.selectedItems, [itemId]: !prevState.selectedItems[itemId] },
          });
        }
      );
    }

    render() {
      return (
        <WrappedComponent
          selectedData={this.state.selectedItems}
          handleSelectData={this.handleSelectItem}
          {...this.props}
        />
      );
    }
  }

  return SelectLogic;
}