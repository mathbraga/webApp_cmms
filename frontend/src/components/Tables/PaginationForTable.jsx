import React, { Component } from 'react';
import { Pagination, PaginationItem, PaginationLink } from 'reactstrap';

class PaginationForTable extends Component {
  constructor(props) {
    super(props);
  }

  handleClickPagination(pageClicked) {
    const { pagesTotal, pageCurrent, setCurrentPage } = this.props;
    switch (pageClicked) {
      case "Primeira": {
        setCurrentPage(1);
        break;
      }
      case "Última": {
        setCurrentPage(pagesTotal);
        break;
      }
      case "-": {
        if (pageCurrent === 1) {
          break;
        }
        setCurrentPage(pageCurrent - 1);
        break;
      }
      case "+": {
        if (pageCurrent === pagesTotal) {
          break;
        }
        setCurrentPage(pageCurrent + 1);
        break;
      }
      default: {
        setCurrentPage(pageClicked);
        break;
      }
    }
  }

  render() {
    const { pagesTotal, pageCurrent } = this.props;
    const visiblePages = [];

    [...Array(5).keys()].forEach(i => {
      let page = pageCurrent + Number(i);
      if (page > 0 && page <= pagesTotal && visiblePages.length < 5 && !visiblePages.includes(page)) {
        visiblePages.push(page);
      }

      page = pageCurrent - Number(i);
      if (page > 0 && page <= pagesTotal && visiblePages.length < 5 && !visiblePages.includes(page)) {
        visiblePages.push(page);
      }
    });

    const listPages = ["Primeira", "-", ...visiblePages.sort((a, b) => (a - b)), "+", "Última"];

    return (
      <Pagination aria-label="Page navigation example">
        {listPages.map(item => (
          <PaginationItem active={item == pageCurrent} >
            <PaginationLink
              onClick={() => this.handleClickPagination(item)}
              style={(item === "Primeira" || item === "Última") ? { width: "80px" } : { width: "auto" }}
            >
              {item}
            </PaginationLink>
          </PaginationItem>
        ))}
      </Pagination>
    );
  }
}

export default PaginationForTable;