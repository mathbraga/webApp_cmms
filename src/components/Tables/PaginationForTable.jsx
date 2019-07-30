import React, { Component } from 'react';
import { Pagination, PaginationItem, PaginationLink } from 'reactstrap';

class PaginationForTable extends Component {
  constructor(props) {
    super(props);
  }

  handleClickPagination(pageClicked) {
    const { pagesTotal, pageCurrent } = this.props;
    switch (pageClicked) {
      case "Primeira": {
        console.log("1");
        break;
      }
      case "Última": {
        console.log(pagesTotal);
        break;
      }
      case "-": {
        console.log(pageCurrent - 1);
        break;
      }
      case "+": {
        console.log(pageCurrent + 1);
        break;
      }
      default: {
        console.log(pageClicked);
        break;
      }
    }
  }

  render() {
    const { pagesTotal, pageCurrent } = this.props;
    const visiblePages = [];

    [...Array(5).keys()].forEach(i => {
      let page = pageCurrent + i;
      if (page > 0 && page <= pagesTotal && visiblePages.length < 5 && !visiblePages.includes(page)) {
        visiblePages.push(page);
      }

      page = pageCurrent - i;
      if (page > 0 && page <= pagesTotal && visiblePages.length < 5 && !visiblePages.includes(page)) {
        visiblePages.push(page);
      }
    });

    const listPages = ["Primeira", "-", ...visiblePages.sort(), "+", "Última"];

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