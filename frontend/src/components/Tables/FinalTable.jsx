import React, { Component } from 'react';
import FinalTableUI from './FinalTableUI';

const ENTRIES_PER_PAGE = 15;

class FinalTable extends Component {
  render() {
    const {
      tableConfig,
      data,
      setGoToPage,
      goToPage,
      setCurrentPage,
      pageCurrent
    } = this.props;

    const pagesTotal = Math.floor(data.length / ENTRIES_PER_PAGE) + 1;
    const visibleData = data.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

    return (
      <FinalTableUI
        tableConfig={tableConfig}
        data={visibleData}
        pagesTotal={pagesTotal}
        pageCurrent={pageCurrent}
        goToPage={goToPage}
        setCurrentPage={setCurrentPage}
        setGoToPage={setGoToPage}
      />
    );
  }
}

export default FinalTable;