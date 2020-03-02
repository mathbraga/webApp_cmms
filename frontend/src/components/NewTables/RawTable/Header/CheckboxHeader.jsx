import React, { Component } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
// CSS
import './Header.css'
// Other components
import { CustomInput } from 'reactstrap';
import Checkbox from '@material-ui/core/Checkbox';

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
        <Checkbox
          size="small"
          indeterminate
          inputProps={{ 'aria-label': 'primary checkbox' }}
        />
      </div>
    </th>
  );
}

CheckboxHeader.propTypes = propTypes;
CheckboxHeader.defaultProps = defaultProps;