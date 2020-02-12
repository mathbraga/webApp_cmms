import React, { Component } from 'react';
import HTMLTable from '../RawTable/HTMLTable';
import PaginationForTable from '../../Paginations/PaginationForTable';
import withPaginationLogic from './withPaginationLogic';
import withSorting from '../TableWithSorting/withSorting';
import { Label, Input } from 'reactstrap';
import { compose } from 'redux';

import './TableWithPages.css'

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
    const { pagesTotal } = this.props
    return (
      <div className="table-container">
        <div className="table-container__pagination-container">
          <div className="page-input-container">
            <span className="page-input-container__page-input-label">Página:</span>
            <input className="page-input-container__page-input"
              type="text"
              name="page"
              value={pageOnInput}
              onChange={handleChangePageOnInput}
              onBlur={handleFocusOutPageOnInput(pagesTotal)}
              onKeyUp={handleEnterPageOnInput}
            />
            <span
              className="page-input-container__display-pages"
              style={{ marginLeft: "10px" }}
            >
              de <span style={{ fontWeight: "bold" }}>{pagesTotal}</span>.
              </span>
          </div>
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