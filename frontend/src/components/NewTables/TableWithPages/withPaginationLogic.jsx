import React, { Component } from 'react';

export default function withPaginationLogic(WrappedComponent) {
  class WithPaginationLogic extends Component {
    constructor(props) {
      super(props);
      this.state = {
        pageOnInput: 1,
        currentPage: 1,
        itensPerPage: 15,
      };

      this.setPageOnInput = this.setPageOnInput.bind(this);
      this.setCurrentPage = this.setCurrentPage.bind(this);
      this.handleChangePageOnInput = this.handleChangePageOnInput.bind(this);
      this.handleFocusOutPageOnInput = this.handleFocusOutPageOnInput.bind(this);
      this.handleEnterPageOnInput = this.handleEnterPageOnInput.bind(this);
      this.handleItensPerPage = this.handleItensPerPage.bind(this);
    }

    setPageOnInput(page) {
      this.setState({ pageOnInput: page });
    }

    setCurrentPage(currentPage) {
      this.setState({ currentPage: currentPage }, () => {
        this.setState({ pageOnInput: currentPage });
      });
    }

    handleItensPerPage(event) {
      const itensPerPage = Number(event.target.value);
      console.log("Event: ", event.target.value);
      this.setState({ itensPerPage }, this.setCurrentPage(1));
    }

    handleChangePageOnInput(event) {
      const { value } = event.target;
      this.setPageOnInput(value);
    }

    handleFocusOutPageOnInput = (pagesTotal) => (event) => {
      const pageOnInput = Number(event.target.value);
      if (pageOnInput >= 1 && pageOnInput <= pagesTotal) {
        this.setCurrentPage(pageOnInput);
      } else {
        this.setPageOnInput(this.state.currentPage);
      }
    }

    handleEnterPageOnInput(event) {
      if (event.key === "Enter") {
        event.target.blur();
      }
    }

    render() {
      const paginationLogic = {
        pageOnInput: this.state.pageOnInput,
        currentPage: this.state.currentPage,
        itensPerPage: this.state.itensPerPage,
        handleChangePageOnInput: this.handleChangePageOnInput,
        handleFocusOutPageOnInput: this.handleFocusOutPageOnInput,
        handleEnterPageOnInput: this.handleEnterPageOnInput,
        setCurrentPage: this.setCurrentPage,
        handleItensPerPage: this.handleItensPerPage
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