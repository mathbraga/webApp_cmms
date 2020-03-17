import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
// CSS
import './Body.css'

const propTypes = {
  columnId: PropTypes.string.isRequired,
  format: PropTypes.string.isRequired
};

// Icons made by <a href="https://www.flaticon.com/authors/dimitry-miroliubov" title="Dimitry Miroliubov">Dimitry Miroliubov</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>

export default function FileIconElement({
  columnId,
  format
}) {
  const IconImage = require('../../../../assets/img/files/pdf.png');
  return (
    <td
      className={classNames({
        "table-body__cell": true,
      })}
      key={columnId}
    >
      <div
        style={{ display: "flex", justifyContent: "center", width: "100%" }}
      >
        <img
          style={{ width: "40px", height: "40px", cursor: "pointer" }}
          src={IconImage}
        />
      </div>
    </td>
  );
}

FileIconElement.propTypes = propTypes;