import React, { Component } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
// CSS
import './Body.css'
// PropTypes
import { selectedDataShape } from '../../__propTypes__/tableConfig';
// Other Components
import { CustomInput } from 'reactstrap';

const propTypes = {
  selectedData: selectedDataShape.isRequired,
  itemId: PropTypes.string.isRequired,
};

export default function CheckboxBodyElement({ selectedData, itemId }) {
  return (
    <td
      className={classNames({
        "table-body__cell": true,
        "table-body__cell--center": true,
      })}
      style={{ width: "5%" }}
      key={"checkbox"}
    >
      <div className="main-table__checkbox">
        <CustomInput
          type="checkbox"
          checked={selectedData[itemId]}
        />
      </div>
    </td>
  );
}

CheckboxBodyElement.propTypes = propTypes;