import React, { Component } from 'react';
import { Row, Col } from 'reactstrap';
import PaginationForTable from './PaginationForTable';
import TableItems from './Table';
import "./TableWithPages.scss";

class TableWithPages extends Component {
  constructor(props) {
    super(props);

    this.handleChangeGoToPage = this.handleChangeGoToPage.bind(this);
    this.handleFocusOutGoToPage = this.handleFocusOutGoToPage.bind(this);
    this.handleEnterGoToPage = this.handleEnterGoToPage.bind(this);
  }

  handleChangeGoToPage(event) {
    const { value } = event.target;
    const { setGoToPage } = this.props;
    setGoToPage(value);
  }

  handleFocusOutGoToPage(event) {
    const { value } = event.target;
    const { pagesTotal, pageCurrent, setCurrentPage, setGoToPage } = this.props;
    const numValue = Number(value);
    if (numValue >= 1 && numValue <= pagesTotal) {
      setCurrentPage(numValue);
    } else {
      setGoToPage(pageCurrent);
    }
  }

  handleEnterGoToPage(event) {
    if (event.key === "Enter") {
      event.target.blur();
    }
  }

  render() {
    const { thead, tbody, pagesTotal, pageCurrent, setCurrentPage, goToPage } = this.props;
    return (
      <div>
        <Row style={{ margin: "15px 0" }}>
          <Col>
            <div className="table-page-container">
              <span className="table-page-label">Página:</span>
              <input className="table-page-input"
                type="text"
                name="page"
                value={goToPage}
                onChange={this.handleChangeGoToPage}
                onBlur={this.handleFocusOutGoToPage}
                onKeyUp={this.handleEnterGoToPage}
              />
              <span
                className="table-page-label"
                style={{ marginLeft: "10px" }}
              > de <span style={{ fontWeight: "bold" }}>{pagesTotal}</span>.
              </span>
            </div>
          </Col>
        </Row>
        <Row>
          <Col>
            <TableItems thead={thead} tbody={tbody} />
          </Col>
        </Row>
        <Row style={{ margin: "15px 0" }}>
          <Col>
            <div className="pagination-container">
              <PaginationForTable pagesTotal={pagesTotal} pageCurrent={pageCurrent} setCurrentPage={setCurrentPage} />
            </div>
          </Col>
        </Row>
      </div>
    );
  }
}

export default TableWithPages;