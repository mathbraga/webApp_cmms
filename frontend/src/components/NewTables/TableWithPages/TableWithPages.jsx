import React, { Component } from 'react';
import HTMLTable from '../RawTable/HTMLTable';
import PaginationForTable from '../../Paginations/PaginationForTable';
import withPaginationLogic from './withPaginationLogic';
import withSorting from '../TableWithSorting/withSorting';
import PageInput from './PageInput';
import SearchInput from '../../Search/SearchInput';
import { Label, Input } from 'reactstrap';
import { compose } from 'redux';

import './TableWithPages.css'

const searchImage = require("../../../assets/icons/search_icon.png");

class TableWithPages extends Component {
  render() {
    const {
      pageOnInput,
      currentPage,
      itensPerPage,
      handleChangePageOnInput,
      handleFocusOutPageOnInput,
      handleEnterPageOnInput,
      setCurrentPage,
      handleItensPerPage
    } = this.props.paginationLogic;

    const {
      hasSearch,
      searchTerm,
      handleChangeSearchTerm,
      pagesTotal
    } = this.props;

    return (
      <div className="table-container">
        <div className="table-container__pagination-container">
          {hasSearch
            ? (<SearchInput
              searchTerm={searchTerm}
              searchImage={searchImage}
              handleChangeSearchTerm={handleChangeSearchTerm}
            />
            )
            : (<PageInput
              pageOnInput={pageOnInput}
              handleChangePageOnInput={handleChangePageOnInput}
              handleFocusOutPageOnInput={handleFocusOutPageOnInput}
              handleEnterPageOnInput={handleEnterPageOnInput}
              pagesTotal={pagesTotal}
            />
            )
          }
          <div className="pagination-container__pagination-selector">
            <PaginationForTable
              pagesTotal={pagesTotal}
              pageCurrent={currentPage}
              setCurrentPage={setCurrentPage}
            />
          </div>
        </div>
        <HTMLTable
          {...this.props}
        />
        <div
          className="table-container__pagination-container"
          style={{ marginTop: "5px" }}
        >
          <div className="itens-per-page-container">
            <Label className="itens-per-page__label" for="itens-per-page">Itens por página: </Label>
            <Input
              type="select"
              name="itens-per-page"
              id="itens-per-page"
              className="itens-per-page__selector"
              value={itensPerPage}
              onChange={handleItensPerPage}
            >
              <option value={5}>5</option>
              <option value={10}>10</option>
              <option value={15}>15</option>
              <option value={25}>25</option>
              <option value={50}>50</option>
              <option value={100}>100</option>
            </Input>
          </div>
          <div className="pagination-container__pagination-selector">
            <PaginationForTable
              pagesTotal={pagesTotal}
              pageCurrent={currentPage}
              setCurrentPage={setCurrentPage}
            />
          </div>
        </div>
      </div>
    );
  }
}

export default compose(
  withSorting,
  withPaginationLogic
)(TableWithPages);