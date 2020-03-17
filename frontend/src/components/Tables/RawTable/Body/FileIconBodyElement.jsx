import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
// CSS
import './Body.css'

const propTypes = {
  columnId: PropTypes.string.isRequired,
};

const fileIconPaths = {
  mp3: '',
  wav: '',
  wma: '',
  zip: '',
  rar: '',
  bin: '',
  iso: '',
  csv: '',
  msg: '',
  ost: '',
  exe: '',
  py: '',
  bmp: '',
  gif: '',
  jpg: '',
  jpeg: '',
  png: '',
  svg: '',
  pps: '',
  ppt: '',
  pptx: '',
  xls: '',
  xlsx: '',
  m4v: '',
  mp4: '',
  mpg: '',
  mpeg: '',
  wmv: '',
  doc: '',
  docx: '',
  txt: '',
}

export default function FileIconBodyElement({
  columnId,
  format
}) {
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
          src={require(fileIconPaths[format])}
        />
      </div>
    </td>
  );
}

FileIconBodyElement.propTypes = propTypes;