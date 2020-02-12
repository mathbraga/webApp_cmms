import React, { Component } from 'react';
import HTMLTable from '../RawTable/HTMLTable';
import PaginationForTable from '../../Paginations/PaginationForTable';
import withPaginationLogic from './withPaginationLogic';
import { Label, Input } from 'reactstrap';

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
    } = this.props.paginationLogic;
    const { data, pagesTotal, visibleData, ...rest } = this.props
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
              onBlur={handleFocusOutPageOnInput}
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
          {...rest}
          data={visibleData}
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
            >
              <option>5</option>
              <option>10</option>
              <option>15</option>
              <option>25</option>
              <option>50</option>
              <option>100</option>
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

export default withPaginationLogic(TableWithPages);