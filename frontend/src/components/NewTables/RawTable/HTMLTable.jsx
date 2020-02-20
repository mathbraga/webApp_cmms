import React, { Component } from 'react';
import './HTMLTable.css';
import classNames from 'classnames';
import { CustomInput } from 'reactstrap';
import PropTypes from 'prop-types';

import HeaderWithSort from './HeaderWithSort/HeaderWithSort';
import CustomHeader from './Header/CustomHeader';
import CheckboxHeader from './Header/CheckboxHeader';

const addTree = require("../../../assets/icons/plus_green.png");
const minusTree = require("../../../assets/icons/minus.png");

function addNestingSpaces(childConfig, columnName, index, handleNestedChildrenClick, openItens) {
  if (columnName === "title") {
    const result = [];
    for (let i = 0; i <= childConfig[index].nestingValue; i++) {
      const element = (
        <div className="add-tree-container">
          <img
            src={!openItens[index] ? addTree : minusTree}
            onClick={handleNestedChildrenClick(index)}
            className={classNames({
              "add-tree-container__icon": true,
              "add-tree-container__icon--hidden": (!childConfig[index].hasChildren || i != childConfig[index].nestingValue)
            })}
          />
        </div>
      );
      result.push(element);
    }
    return result;
  }
}

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
      parents,
      handleNestedChildrenClick,
      openItens,
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
                      <td
                        className={classNames({
                          "main-table__data": true,
                          "main-table__data--center": true,
                        })}
                        style={{ width: "5%" }}
                        key={"checkbox"}
                      >
                        <div className="main-table__checkbox">
                          <CustomInput
                            type="checkbox"
                            checked={selectedData[item[tableConfig.idAttributeForData]]}
                          />
                        </div>
                      </td>
                    )}
                    {tableConfig.columns.map((column) => (
                      <td
                        className={classNames({
                          "main-table__data": true,
                        })}
                        key={column.name}
                      >
                        <div
                          className={classNames({
                            [`main-table__data--${column.align}`]: column.align,
                          })}
                          style={{ display: "flex", alignItems: "center" }}
                        >
                          {addNestingSpaces(childConfig, column.name, item[tableConfig.idAttributeForData], handleNestedChildrenClick, openItens)}
                          <div style={{ display: "block" }}>
                            <div className={classNames({
                              "main-table__data-value": true,
                              "main-table__data--nowrap": !column.wrapText,
                            })}>
                              {item[column.data[0]]}
                            </div>
                            {column.data[1] && (
                              <div className={classNames({
                                "main-table__data-sub-value": true,
                              })}
                              >
                                {item[column.data[1]]}
                              </div>
                            )}
                          </div>
                        </div>
                      </td>
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