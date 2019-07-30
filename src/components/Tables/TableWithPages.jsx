import React, { Component } from 'react';
import { Pagination, PaginationItem, PaginationLink, Row, Col } from 'reactstrap';
import TableItems from './Table';
import "./TableWithPages.scss";

class TableWithPages extends Component {
  render() {
    const { thead, tbody } = this.props;
    return (
      <div>
        <Row style={{ margin: "15px 0" }}>
          <Col>
            <div className="table-page-container">
              <span className="table-page-label">Ir para página:</span>
              <input className="table-page-input" type="text" name="page" value="1" />
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
              <Pagination aria-label="Page navigation example">
                <PaginationItem style={{ width: "80px" }}>
                  <PaginationLink href="#3">
                    Primeira
                </PaginationLink>
                </PaginationItem>
                <PaginationItem>
                  <PaginationLink href="#3">
                    -
                </PaginationLink>
                </PaginationItem>
                <PaginationItem active>
                  <PaginationLink href="#3">
                    1
                </PaginationLink>
                </PaginationItem>
                <PaginationItem>
                  <PaginationLink href="#4">
                    2
                </PaginationLink>
                </PaginationItem>
                <PaginationItem>
                  <PaginationLink href="#4">
                    3
                </PaginationLink>
                </PaginationItem>
                <PaginationItem>
                  <PaginationLink href="#4">
                    4
                </PaginationLink>
                </PaginationItem>
                <PaginationItem>
                  <PaginationLink href="#4">
                    5
                </PaginationLink>
                </PaginationItem>
                <PaginationItem>
                  <PaginationLink href="#4">
                    +
                </PaginationLink>
                </PaginationItem>
                <PaginationItem style={{ width: "80px", textAlign: "center" }}>
                  <PaginationLink href="#4">
                    Última
                </PaginationLink>
                </PaginationItem>
              </Pagination>
            </div>
          </Col>
        </Row>
      </div>
    );
  }
}

export default TableWithPages;