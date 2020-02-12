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
    }

    setPageOnInput(page) {
      this.setState({ pageOnInput: page });
    }

    setCurrentPage(currentPage) {
      this.setState({ currentPage: currentPage }, () => {
        this.setState({ pageOnInput: currentPage });
      });
    }

    handleChangePageOnInput(event) {
      const { value } = event.target;
      this.setPageOnInput(value);
    }

    handleFocusOutPageOnInput(event) {
      const pageOnInput = Number(event.target.value);
      const { pagesTotal } = this.props;
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
      }

      const { itensPerPage, currentPage } = this.state;
      const { data } = this.props;

      const pagesTotal = Math.floor(data.length / itensPerPage) + 1;
      const visibleData = data.slice((currentPage - 1) * itensPerPage, currentPage * itensPerPage);

      return (
        <WrappedComponent
          paginationLogic={paginationLogic}
          pagesTotal={pagesTotal}
          visibleData={visibleData}
          {...this.props}
        />
      );
    }
  }
  return WithPaginationLogic;
}