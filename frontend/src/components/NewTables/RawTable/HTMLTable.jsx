import React, { Component } from 'react';
import './HTMLTable.css';
import classNames from 'classnames';
import { CustomInput } from 'reactstrap';

const sortingArrow = require("../../../assets/icons/sorting_arrow.png");
const addTree = require("../../../assets/icons/add.png");

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

function addNestingSpaces(childConfig, columnName, index, handleNestedChildrenClick) {
  if (columnName === "title") {
    const result = [];
    for (let i = 0; i <= childConfig[index].nestingValue; i++) {
      const element = (
        <div className="add-tree-container">
          <img
            src={addTree}
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

function assignParents(data, childConfig, tableConfig) {
  const result = {};
  let lastNestingValue = false;
  let lastItemId = false;
  let parents = [];
  data.forEach((item) => {
    const id = item[tableConfig.idAttributeForData];
    const { nestingValue } = childConfig[id];
    if (lastNestingValue !== false) {
      if (nestingValue > lastNestingValue) {
        parents.push(lastItemId);
      } else if (nestingValue < lastNestingValue) {
        parents = parents.slice(0, nestingValue);
      }
    }
    result[id] = [...parents];
    lastNestingValue = nestingValue;
    lastItemId = id;
  })
  return result;
}

function createDataWithoutClosedItens(data, parents, openItens, tableConfig) {
  return (data.filter((item) => {
    const id = item[tableConfig.idAttributeForData];
    return parents[id].every((parent) => openItens[parent]);
  }));
}

class HTMLTable extends Component {
  constructor(props) {
    super(props);
    this.state = {
      openItens: {},
    }
  }

  handleNestedChildrenClick = (id) => () => {
    this.setState((prevState) => ({
      openItens: { ...prevState.openItens, [id]: !prevState.openItens[id] }
    }))
  }

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
    } = this.props;
    console.log("ChildConfig: ", childConfig);
    const parents = assignParents(data, childConfig, tableConfig);
    console.log("Parents: ", parents);
    const dataWithoutClosedItens = createDataWithoutClosedItens(data, parents, this.state.openItens, tableConfig);
    const visibleData = dataWithoutClosedItens.slice((currentPage - 1) * itensPerPage, currentPage * itensPerPage);
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
                          {addNestingSpaces(childConfig, column.name, item[tableConfig.idAttributeForData], this.handleNestedChildrenClick)}
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