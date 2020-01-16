import React, { Component } from 'react';
import withPaginationLogic from '../PageLogicContainer';
import CardWithTableUI from './CardWithTableUI';
import searchList from '../../utils/search/searchList';
import filterList from '../../utils/filter/filter';
import { compose } from 'redux';

const ENTRIES_PER_PAGE = 15;

class CardWithTable extends Component {
  constructor(props) {
    super(props);
    this.state = {
      filterSavedId: null,
      searchTerm: "",
      filterLogic: [],
    }

    this.updateCurrentFilter = this.updateCurrentFilter.bind(this);
    this.handleChangeSearchTerm = this.handleChangeSearchTerm.bind(this);
  }

  updateCurrentFilter(filterLogic, filterName, filterId = null) {
    this.setState({
      filterLogic,
      filterName,
      filterSavedId: filterId
    }, () => this.props.paginationLogic.setCurrentPage(1));
  }

  handleChangeSearchTerm(event) {
    this.setState({
      searchTerm: event.target.value
    }, () => this.props.paginationLogic.setCurrentPage(1));
  }

  // Put all the extra logic here.

  render() {
    const {
      paginationLogic,
      tableConfig,
      customFilters,
      filterAttributes,
      searchableAttributes,
      data
    } = this.props;

    const dataWithFilter = this.state.filterLogic.length > 0 ? filterList(data, this.state.filterLogic) : data;
    const dataWithSearchAndFilter = searchList(dataWithFilter, searchableAttributes, this.state.searchTerm);
    const totalOfPages = Math.floor(dataWithSearchAndFilter.length / ENTRIES_PER_PAGE) + 1;


    return (
      <CardWithTableUI
        tableConfig={tableConfig}
        goToPage={paginationLogic.goToPage}
        pageCurrent={paginationLogic.pageCurrent}
        setGoToPage={paginationLogic.setGoToPage}
        setCurrentPage={paginationLogic.setCurrentPage}
        updateCurrentFilter={this.updateCurrentFilter}
        filterSavedId={this.state.filterSavedId}
        searchTerm={this.state.searchTerm}
        handleChangeSearchTerm={this.handleChangeSearchTerm}
        filterLogic={this.state.filterLogic}
        filterName={this.state.filterName}
        numberOfItens={totalOfPages}
        data={dataWithSearchAndFilter}
        customFilters={customFilters}
        filterAttributes={filterAttributes}
      />
    );
  }
}

export default compose(
  withPaginationLogic
)(CardWithTable);