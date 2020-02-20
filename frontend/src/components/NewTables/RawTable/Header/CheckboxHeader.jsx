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

export default function CheckboxHeader({ width }) {
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
        <CustomInput
          type="checkbox"
        />
      </div>
    </th>
  );
}

CheckboxHeader.propTypes = propTypes;
CheckboxHeader.defaultProps = defaultProps;