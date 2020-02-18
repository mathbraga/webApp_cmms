import React, { Component } from 'react';
import './HTMLTable.css';
import classNames from 'classnames';
import { CustomInput } from 'reactstrap';

const sortingArrow = require("../../../assets/icons/sorting_arrow.png");
const addTree = require("../../../assets/icons/plus_green.png");
const minusTree = require("../../../assets/icons/minus.png");

function HeaderButton({ onClick, children, className }) {
  return (
    <div onClick={onClick} className={classNames("main-table__head-button", className)}>
      {children}
    </div>
  );
}

function HeaderSort({ sortKey, onSort, children, activeSortKey, isSortReverse }) {
  return (
    <HeaderButton onClick={() => onSort(sortKey)}>
      {children}
      {activeSortKey === sortKey && (
        <div className={classNames({
          "main-table__head-arrow": true,
          "main-table__head-arrow--rotated": isSortReverse
        })}>
          <img src={sortingArrow} />
        </div>
      )}
    </HeaderButton>
  );
}

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
    console.log("Data: ", data);
    console.log("Parents: ", parents);
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
                    <th
                      className={classNames({
                        "main-table__head": true,
                        "main-table__head--center": true,
                      })}
                      style={{ width: tableConfig.checkboxWidth || "5%" }}
                      key={"checkbox"}
                    >
                      <div className="main-table__checkbox">
                        <CustomInput
                          type="checkbox"
                        />
                      </div>
                    </th>
                  )}
                  {tableConfig.columns.map((column) => (
                    <th
                      className={classNames({
                        "main-table__head": true,
                        [`main-table__head--${column.align}`]: column.align,
                      })}
                      style={{ width: column.width }}
                      key={column.name}
                    >
                      <div className="main-table__head-value">
                        {
                          onSort === false
                            ? (
                              column.description
                            )
                            : (
                              <HeaderSort sortKey={column.name} onSort={onSort} activeSortKey={activeSortKey} isSortReverse={isSortReverse}>
                                {column.description}
                              </HeaderSort>
                            )
                        }
                      </div>
                    </th>
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