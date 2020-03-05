import React, { Component } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
// CSS
import './Header.css'
// Other components
import { CustomInput } from 'reactstrap';

const propTypes = {
  width: PropTypes.string,
};

const defaultProps = {
  width: "5%",
};

export default function CheckboxHeader({ width, selectedData, visibleData, attForDataId, handleSelectData }) {
  let checked = true;
  visibleData.forEach((item) => {
    const itemId = item[attForDataId]
    checked = checked && selectedData[itemId];
  });

  function handleSelectAllData() {
    if (checked) {
      visibleData.forEach((item) => {
        const itemId = item[attForDataId];
        if (selectedData[itemId]) {
          handleSelectData(itemId)();
        }
      })
    } else {
      visibleData.forEach((item) => {
        const itemId = item[attForDataId];
        if (!selectedData[itemId]) {
          handleSelectData(itemId)();
        }
      })
    }
  }

  return (
    <th
      className={classNames({
        "header-container": true,
        "header-container--center": true,
      })}
      style={{ width }}
      key={"checkbox"}
    >
      <div className="header-container__checkbox">
        <div
          onClick={handleSelectAllData}
        >
          <CustomInput
            type="checkbox"
            checked={checked}
          />
        </div>
      </div>
    </th>
  );
}

CheckboxHeader.propTypes = propTypes;
CheckboxHeader.defaultProps = defaultProps;