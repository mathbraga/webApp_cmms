import React, { Component } from 'react';
import 'CompactTable.css';
import HTMLTable from '../RawTable/HTMLTable';

const propTypes = {
  data: PropTypes.array,
  tableConfig: tableConfigShape,
  selectedData: selectedDataShape,
  handleSelectData: PropTypes.func,
  // TODO
  searchableAttributes: PropTypes.any,
  filterAttributes: PropTypes.any,
  customFilters: PropTypes.any,
  // Props from HOCS:
  parents: PropTypes.any,
  searchTerm: PropTypes.any,
  handleChangeSearchTerm: PropTypes.any,
  filterLogic: PropTypes.any,
  filterName: PropTypes.any,
  filterSavedId: PropTypes.any,
  updateCurrentFilter: PropTypes.any,
};

class CompactTable extends Component {
  state = {  }
  render() { 
    return ( 
      <HTMLTable
          data={data}
          attForDataId={tableConfig.attForDataId}
          hasCheckbox={tableConfig.hasCheckbox}
          checkboxWidth={tableConfig.checkboxWidth}
          isItemClickable={tableConfig.isItemClickable}
          dataAttForClickable={tableConfig.dataAttForClickable}
          itemPathWithoutID={tableConfig.itemPathWithoutID}
          columnsConfig={tableConfig.columnsConfig}
          selectedData={selectedData}
          handleSelectData={handleSelectData}
          currentPage={currentPage}
          itemsPerPage={itemsPerPage}
          activeSortKey={activeSortKey}
          isSortReverse={isSortReverse}
          onSort={onSort}
          isDataTree={tableConfig.isDataTree}
          idForNestedTable={tableConfig.idForNestedTable}
          childConfig={childConfig}
          handleNestedChildrenClick={handleNestedChildrenClick}
          openitems={openitems}
          actionColumn={tableConfig.actionColumn}
          actionColumnWidth={tableConfig.actionColumnWidth}
          isFileTable={tableConfig.isFileTable}
          fileColumnWidth={tableConfig.fileColumnWidth}
        />
     );
  }
}
 
export default CompactTable;