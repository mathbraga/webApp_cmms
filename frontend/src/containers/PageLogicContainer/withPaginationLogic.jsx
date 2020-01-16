import React, { Component } from 'react';

export default function withPaginationLogic(WrappedComponent) {
  class WithPaginationLogic extends Component {
    constructor(props) {
      super(props);
      this.state = {
        goToPage: 1,
        pageCurrent: 1
      };

      this.setGoToPage = this.setGoToPage.bind(this);
      this.setCurrentPage = this.setCurrentPage.bind(this);
    }

    setGoToPage(page) {
      this.setState({ goToPage: page });
    }

    setCurrentPage(pageCurrent) {
      this.setState({ pageCurrent: pageCurrent }, () => {
        this.setState({ goToPage: pageCurrent });
      });
    }

    render() {
      const paginationLogic = {
        goToPage: this.state.goToPage,
        pageCurrent: this.state.pageCurrent,
        setGoToPage: this.setGoToPage,
        setCurrentPage: this.setCurrentPage
      }
      return (
        <WrappedComponent
          paginationLogic={paginationLogic}
        />
      );
    }
  }
  return WithPaginationLogic;
}