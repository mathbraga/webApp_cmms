import React, { Component } from 'react';
import withPaginationLogic from '../TableWithPages/withPaginationLogic';
import CardTableUI from './TableFilterUI';
import searchList from '../../../utils/search/searchList';
import filterList from '../../../utils/filter/filter';
import { compose } from 'redux';

const ENTRIES_PER_PAGE = 15;

class TableFilter extends Component {
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
      title,
      subtitle,
      buttonName,
      paginationLogic,
      tableConfig,
      customFilters,
      filterAttributes,
      searchableAttributes,
      hasAssetCard,
      data
    } = this.props;

    const dataWithFilter = this.state.filterLogic.length > 0 ? filterList(data, this.state.filterLogic) : data;
    const dataWithSearchAndFilter = searchList(dataWithFilter, searchableAttributes, this.state.searchTerm);
    const totalOfPages = Math.floor(dataWithSearchAndFilter.length / ENTRIES_PER_PAGE) + 1;


    return (
      <CardTableUI
        title={title}
        subtitle={subtitle}
        buttonName={buttonName}
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
        numberOfItens={dataWithSearchAndFilter.length}
        data={dataWithSearchAndFilter}
        customFilters={customFilters}
        filterAttributes={filterAttributes}
        hasAssetCard={hasAssetCard}
      />
    );
  }
}

export default compose(
  withPaginationLogic
)(TableFilter);