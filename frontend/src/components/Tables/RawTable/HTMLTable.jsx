import React, { Component } from 'react';
import './HTMLTable.css';
import classNames from 'classnames';
import PropTypes from 'prop-types';
import { withRouter } from "react-router";
// PropTypes
import { selectedDataShape, actionColumnShape, columnsConfigShape } from '../__propTypes__/tableConfig';
import { childConfigShape, openItemsShape } from '../__propTypes__/nestedTable';
// Components
import CustomHeader from './Header/CustomHeader';
import CheckboxHeader from './Header/CheckboxHeader';
import CustomBodyElement from './Body/CustomBodyElement';
import CheckboxBodyElement from './Body/CheckboxBodyElement';
import ActionBodyElement from './Body/ActionBodyElement';
import FileIconElement from './Body/FileIconElement';

const propTypes = {
  data: PropTypes.array,
  attForDataId: PropTypes.string.isRequired,
  hasCheckbox: PropTypes.bool,
  checkboxWidth: PropTypes.string,
  isItemClickable: PropTypes.bool,
  itemPathWithoutID: PropTypes.string,
  columnsConfig: PropTypes.arrayOf(columnsConfigShape),
  selectedData: selectedDataShape,
  currentPage: PropTypes.number.isRequired,
  itemsPerPage: PropTypes.number.isRequired,
  activeSortKey: PropTypes.string,
  isSortReverse: PropTypes.bool,
  onSort: PropTypes.func,
  isDataTree: PropTypes.bool,
  idForNestedTable: PropTypes.string,
  childConfig: childConfigShape,
  handleNestedChildrenClick: PropTypes.func,
  openitems: openItemsShape,
  actionColumn: actionColumnShape,
  actionColumnWidth: PropTypes.string,
  isFileTable: PropTypes.bool,
  fileColumnWidth: PropTypes.string
};

const defaultProps = {
  data: [],
  hasCheckbox: false,
  checkboxWidth: "5%",
  selectedData: {},
  isSortReverse: false,
  isDataTree: false,
};

class HTMLTable extends Component {
  render() {
    const {
      data,
      attForDataId,
      hasCheckbox,
      checkboxWidth,
      isItemClickable,
      dataAttForClickable,
      itemPathWithoutID,
      columnsConfig,
      selectedData,
      handleSelectData,
      currentPage,
      itemsPerPage,
      activeSortKey,
      isSortReverse,
      onSort,
      isDataTree,
      idForNestedTable,
      childConfig,
      handleNestedChildrenClick,
      openitems,
      actionColumn,
      actionColumnWidth,
      isFileTable,
      fileColumnWidth
    } = this.props;
    const visibleData = data.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);
    return (
      <div className="table-wrapper">
        {visibleData.length === 0
          ? (
            <div className="table-no-item">Página sem items.</div>
          )
          : (
            <table className="main-table">
              <thead className="main-table__header">
                <tr
                  className="main-table__header__row"
                  key="header"
                >
                  {hasCheckbox && (
                    <CheckboxHeader
                      width={checkboxWidth}
                      selectedData={selectedData}
                      visibleData={visibleData}
                      attForDataId={attForDataId}
                      handleSelectData={handleSelectData}
                    />
                  )}
                  {isFileTable && (
                    <CustomHeader
                      id={"format"}
                      value={""}
                      align={"center"}
                      width={fileColumnWidth}
                    />
                  )}
                  {columnsConfig.map((column) => (
                    <CustomHeader
                      id={column.columnId}
                      key={column.columnId}
                      value={column.columnName}
                      align={column.align}
                      width={column.width}
                      sortKey={column.columnId}
                      activeSortKey={activeSortKey}
                      isSortReverse={isSortReverse}
                      onSort={onSort}
                    />
                  ))}
                  {actionColumn && (
                    <CustomHeader
                      id={"action"}
                      value={"Ações"}
                      align={"center"}
                      width={actionColumnWidth}
                    />
                  )}
                </tr>
              </thead>
              <tbody className="main-table__body">
                {visibleData.map((item) => (
                  <tr
                    className={classNames({
                      "main-table__body__row": true,
                      "main-table__body__row--selected": selectedData[item[attForDataId]],
                    })}
                    key={item[attForDataId]}
                  >
                    {hasCheckbox && (
                      <CheckboxBodyElement
                        selectedData={selectedData}
                        handleSelectData={handleSelectData}
                        itemId={item[attForDataId]}
                      />
                    )}
                    {isFileTable && (
                      <FileIconElement
                        columnId={"file"}
                        format={item.format}
                      />
                    )}
                    {columnsConfig.map((column) => {
                      let dataValue = column.idForValues && item[column.idForValues[0]];
                      if (column.idForValues && column.idForValues[0] && column.createElementWithData) {
                        dataValue = column.createElementWithData(item[column.idForValues[0]], item);
                      }

                      let dataSubValue = column.idForValues && item[column.idForValues[1]];
                      if (column.idForValues && column.idForValues[1] && column.createElementWithSubData) {
                        dataSubValue = column.createElementWithSubData(item[column.idForValues[1]], item);
                      }

                      return (
                        <CustomBodyElement
                          columnId={column.columnId}
                          itemId={item[attForDataId]}
                          key={column.columnId}
                          createElement={column.createElement || null}
                          dataValue={dataValue || ""}
                          hasDataSubValue={column.idForValues && Boolean(column.idForValues[1])}
                          dataSubValue={dataSubValue}
                          isItemClickable={isItemClickable}
                          dataAttForClickable={dataAttForClickable}
                          itemPathWithoutID={itemPathWithoutID}
                          isDataTree={isDataTree}
                          idForNestedTable={idForNestedTable}
                          childConfig={childConfig}
                          handleNestedChildrenClick={handleNestedChildrenClick}
                          openitems={openitems}
                          align={column.align}
                          isTextWrapped={column.isTextWrapped}
                          history={this.props.history}
                        />
                      );
                    }
                    )}
                    {actionColumn && (
                      <ActionBodyElement
                        columnId={"action"}
                        itemId={item[attForDataId]}
                        actionType={actionColumn}
                        handleAction={{
                          "delete": (id) => () => { console.log("OK1") },
                          "edit": (id) => () => { console.log("OK2") }
                        }}
                        openItems={openitems}
                      />
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          )
        }
      </div>
    );
  }
}

export default withRouter(HTMLTable);

HTMLTable.propTypes = propTypes;
HTMLTable.defaultProps = defaultProps;