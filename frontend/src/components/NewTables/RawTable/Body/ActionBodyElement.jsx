import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
// CSS
import './Body.css'
// Proptypes
import { openItemsShape } from '../../__propTypes__/nestedTable';

const propTypes = {
  columnId: PropTypes.string.isRequired,
  itemId: PropTypes.string.isRequired,
  actionType: PropTypes.array,
  handleAction: PropTypes.arrayOf(PropTypes.func),
  openItems: openItemsShape,
};

export default function ActionBodyElement({
  columnId,
  itemId,
  actionType,
  handleAction,
  openItems,
}) {
  return (
    <td
      className={classNames({
        "table-body__cell": true,
      })}
      key={columnId}
    >
      <div
        className={classNames({
          [`table-body__cell--${align}`]: align,
        })}
        style={{ display: "flex", alignItems: "center" }}
      >
        {isDataTree && addNestingSpaces(childConfig, columnId, itemId, handleNestedChildrenClick, openitems, idForNestedTable)}
        <div
          style={{ display: "block" }}
          className={classNames({
            "table-body__cell--clickable": isItemClickable && (dataAttForClickable === columnId),
          })}
          onClick={isItemClickable && (dataAttForClickable === columnId) && (
            () => {
              history.push(itemPathWithoutID + itemId)
            })}
        >
          <div className={classNames({
            "table-body__cell__value": true,
            "table-body__cell--nowrap": !isTextWrapped,
          })}>
            {dataValue}
          </div>
          {hasDataSubValue && (
            <div className={classNames({
              "table-body__cell__sub-value": true,
            })}
            >
              {dataSubValue}
            </div>
          )}
        </div>
      </div>
    </td>
  );
}

ActionBodyElement.propTypes = propTypes;