import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
// CSS
import './HeaderWithSort.css';

const propTypes = {
  onClick: PropTypes.func.isRequired,
  children: PropTypes.node,
  className: PropTypes.string,
};

const defaultProps = {
  children: "Coluna",
  className: ""
};

export default function HeaderButton({ onClick, children, className }) {
  return (
    <div onClick={onClick} className={classNames("header__head-button", className)}>
      {children}
    </div>
  );
}

HeaderButton.propTypes = propTypes;
HeaderButton.defaultProps = defaultProps;