import React, { Component } from 'react';
import './HTMLTable.css';
import classNames from 'classnames';
import PropTypes from 'prop-types';

import CustomHeader from './Header/CustomHeader';
import CheckboxHeader from './Header/CheckboxHeader';
import CustomBodyElement from './Body/CustomBodyElement';
import CheckboxBodyElement from './Body/CheckboxBodyElement';

class HTMLTable extends Component {
  render() {
    const {
      onSort,
      activeSortKey,
      data,
      tableConfig,
      selectedData,
      isSortReverse,
      childConfig,
      currentPage,
      itensPerPage,
      handleNestedChildrenClick,
      openItens,
      isDataTree
    } = this.props;
    const visibleData = data.slice((currentPage - 1) * itensPerPage, currentPage * itensPerPage);
    return (
      <div className="table-wrapper">
        {visibleData.length === 0
          ? (
            <div className="table-no-item">Página sem itens.</div>
          )
          : (
            <table className="main-table">
              <thead className="main-table__header">
                <tr
                  className="main-table__header__row"
                  key="header"
                >
                  {tableConfig.checkbox && (
                    <CheckboxHeader
                      width={tableConfig.checkboxWidth}
                    />
                  )}
                  {tableConfig.columns.map((column) => (
                    <CustomHeader
                      id={column.name}
                      value={column.description}
                      align={column.align}
                      width={column.width}
                      sortKey={column.name}
                      activeSortKey={activeSortKey}
                      isSortReverse={isSortReverse}
                      onSort={onSort}
                    />
                  ))}
                </tr>
              </thead>
              <tbody className="main-table__body">
                {visibleData.map((item) => (
                  <tr
                    className={classNames({
                      "main-table__body__row": true,
                      "main-table__body__row--selected": selectedData[item[tableConfig.idAttributeForData]],
                    })}
                    key={item[tableConfig.idAttributeForData]}
                  >
                    {tableConfig.checkbox && (
                      <CheckboxBodyElement
                        selectedData={selectedData}
                        itemId={item[tableConfig.idAttributeForData]}
                      />
                    )}
                    {tableConfig.columns.map((column) => (
                      <CustomBodyElement
                        columnId={column.name}
                        itemId={item[tableConfig.idAttributeForData]}
                        dataValue={item[column.data[0]]}
                        hasDataSubValue={Boolean(column.data[1])}
                        dataSubValue={item[column.data[1]]}
                        isDataTree={isDataTree}
                        childConfig={childConfig}
                        handleNestedChildrenClick={handleNestedChildrenClick}
                        openItens={openItens}
                        align={column.align}
                        isTextWrapped={column.wrapText}
                      />
                    ))}
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

export default HTMLTable;