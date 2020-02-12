import React, { Component } from 'react';
import HTMLTable from '../RawTable/HTMLTable';
import PaginationForTable from '../../Paginations/PaginationForTable';
import { Label, Input } from 'reactstrap';

import './TableWithPages.css'

class TableWithPages extends Component {
  render() {
    return (
      <div className="table-container">
        <div className="table-container__pagination-container">
          <div className="page-input-container">
            <span className="page-input-container__page-input-label">Página:</span>
            <input className="page-input-container__page-input"
              type="text"
              name="page"
              value={1}
            // onChange={this.handleChangeGoToPage}
            // onBlur={this.handleFocusOutGoToPage}
            // onKeyUp={this.handleEnterGoToPage}
            />
            <span
              className="page-input-container__display-pages"
              style={{ marginLeft: "10px" }}
            >
              de <span style={{ fontWeight: "bold" }}>{200}</span>.
              </span>
          </div>
          <div className="pagination-container__pagination-selector">
            <PaginationForTable
              pagesTotal={10}
              pageCurrent={1}
              setCurrentPage={() => (console.log("Hi"))}
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
              pagesTotal={10}
              pageCurrent={1}
              setCurrentPage={() => (console.log("Hi"))}
            />
          </div>
        </div>
      </div>
    );
  }
}

export default TableWithPages;