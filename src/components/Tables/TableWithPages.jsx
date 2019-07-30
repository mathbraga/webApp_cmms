import React, { Component } from 'react';
import { Row, Col } from 'reactstrap';
import PaginationForTable from './PaginationForTable';
import TableItems from './Table';
import "./TableWithPages.scss";

class TableWithPages extends Component {
  constructor(props) {
    super(props);
    this.state = {
      pagesTotal: 10,
      pageCurrent: 5,
      goToPage: 5
    };

    this.setCurrentPage = this.setCurrentPage.bind(this);
    this.handleChangeGoToPage = this.handleChangeGoToPage.bind(this);
  }

  setCurrentPage(pageCurrent) {
    this.setState({ pageCurrent: pageCurrent, goToPage: pageCurrent });
  }

  handleChangeGoToPage(event) {
    const { value } = event.target;
    this.setState({ goToPage: value });
  }

  render() {
    const { thead, tbody } = this.props;
    const { pagesTotal, pageCurrent, goToPage } = this.state;
    return (
      <div>
        <Row style={{ margin: "15px 0" }}>
          <Col>
            <div className="table-page-container">
              <span className="table-page-label">Ir para página:</span>
              <input className="table-page-input"
                type="text"
                name="page"
                value={goToPage}
                onChange={this.handleChangeGoToPage}
              />
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
              <PaginationForTable pagesTotal={pagesTotal} pageCurrent={pageCurrent} setCurrentPage={this.setCurrentPage} />
            </div>
          </Col>
        </Row>
      </div>
    );
  }
}

export default TableWithPages;