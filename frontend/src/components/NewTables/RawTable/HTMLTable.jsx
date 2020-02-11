import React, { Component } from 'react';
import './HTMLTable.css';
import classNames from 'classnames';
import { CustomInput } from 'reactstrap';
import withSorting from '../TableWithSorting/withSorting';

const sortingArrow = require("../../../assets/icons/sorting_arrow.png");

function HeaderButton({ onClick, children, className }) {
  return (
    <div onClick={onClick} className={classNames("main-table__head-button", className)}>
      {children}
    </div>
  );
}

function HeaderSort({ sortKey, onSort, children, activeSortKey }) {
  return (
    <HeaderButton onClick={() => onSort(sortKey)}>
      {children}
      {activeSortKey === sortKey && (
        <div className="main-table__head-arrow">
          <img src={sortingArrow} />
        </div>
      )}
    </HeaderButton>
  );
}

class HTMLTable extends Component {
  render() {
    const { onSort, activeSortKey, data, tableConfig, selectedData } = this.props;
    return (
      <div className="table-wrapper">
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
                          <HeaderSort sortKey={column.name} onSort={onSort} activeSortKey={activeSortKey}>
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
            {data.map((item) => (
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
                      [`main-table__data--${column.align}`]: column.align,
                    })}
                    key={column.name}
                  >
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
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  }
}

export default withSorting(HTMLTable);