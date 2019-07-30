import React, { Component } from 'react';
import { Row, Col } from 'reactstrap';
import PaginationForTable from './PaginationForTable';
import TableItems from './Table';
import "./TableWithPages.scss";

class TableWithPages extends Component {
  constructor(props) {
    super(props)
    this.state = {
      pagesTotal: 10,
      pageCurrent: 5,
    }
  }

  render() {
    const { thead, tbody } = this.props;
    const { pagesTotal, pageCurrent } = this.state;
    return (
      <div>
        <Row style={{ margin: "15px 0" }}>
          <Col>
            <div className="table-page-container">
              <span className="table-page-label">Ir para página:</span>
              <input className="table-page-input" type="text" name="page" value={pageCurrent} />
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
              <PaginationForTable pagesTotal={pagesTotal} pageCurrent={pageCurrent} />
            </div>
          </Col>
        </Row>
      </div>
    );
  }
}

export default TableWithPages;