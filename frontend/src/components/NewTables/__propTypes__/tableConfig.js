import PropTypes from 'prop-types';

export const alignShape = PropTypes.oneOf(['center', 'justify']);

export const selectedDataShape = PropTypes.objectOf(PropTypes.bool);

export const tableConfigShape = PropTypes.shape({
  idAttributeForData: PropTypes,
  checkbox: PropTypes,
  checkboxWidth: PropTypes,
  columns: PropTypes,
});

export const columnsConfigShape = PropTypes.shape({
  columnId: PropTypes.string.isRequired,
  columnName: PropTypes.string.isRequired,
  idForValues: PropTypes.arrayOf(PropTypes.string).isRequired,
  align: PropTypes.string,
  width: PropTypes.string,
  isTextWrapped: PropTypes.bool,
});