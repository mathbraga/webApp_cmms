import React, { Component } from 'react';

export default function withPaginationLogic(WrappedComponent) {
  class WithPaginationLogic extends Component {
    constructor(props) {
      super(props);
      this.state = {
        pageOnInput: 1,
        currentPage: 1
      };

      this.setPageOnInput = this.setPageOnInput.bind(this);
      this.setCurrentPage = this.setCurrentPage.bind(this);
    }

    setPageOnInput(page) {
      this.setState({ pageOnInput: page });
    }

    setCurrentPage(currentPage) {
      this.setState({ currentPage: currentPage }, () => {
        this.setState({ pageOnInput: currentPage });
      });
    }

    render() {
      const paginationLogic = {
        pageOnInput: this.state.pageOnInput,
        currentPage: this.state.currentPage,
        setPageOnInput: this.setPageOnInput,
        setCurrentPage: this.setCurrentPage
      }
      return (
        <WrappedComponent
          paginationLogic={paginationLogic}
          {...this.props}
        />
      );
    }
  }
  return WithPaginationLogic;
}