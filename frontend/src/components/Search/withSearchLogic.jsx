import React, { Component } from 'react';
import searchList from '../../utils/search/searchList';

function withSearchLogic(WrappedComponent) {
  class WithSearchLogic extends Component {
    constructor(props) {
      super(props);
      this.state = {
        searchTerm: "",
      }
      this.handleChangeSearchTerm = this.handleChangeSearchTerm.bind(this);
    }

    handleChangeSearchTerm(event) {
      if (this.props.paginationLogic) {
        this.setState({
          searchTerm: event.target.value
        }, () => this.props.paginationLogic.setCurrentPage(1));
      } else {
        this.setState({
          searchTerm: event.target.value
        });
      }

    }

    render() {
      const {
        data,
        searchableAttributes
      } = this.props;
      console.log("Data Search: ", data);
      const dataWithSearch = searchList(data.data, searchableAttributes, this.state.searchTerm);
      return (
        <WrappedComponent
          {...this.props}
          searchTerm={this.state.searchTerm}
          data={dataWithSearch}
          handleChangeSearchTerm={this.handleChangeSearchTerm}
        />
      );
    }
  }

  return WithSearchLogic;
}

export default withSearchLogic;