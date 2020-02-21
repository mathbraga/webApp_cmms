import PropTypes from 'prop-types';

export const alignShape = PropTypes.oneOf(['center', 'justify']);

export const selectedDataShape = PropTypes.objectOf(PropTypes.bool);

export const columnsConfigShape = PropTypes.shape({
  columnId: PropTypes.string.isRequired,
  columnName: PropTypes.string.isRequired,
  idForValues: PropTypes.arrayOf(PropTypes.string).isRequired,
  align: PropTypes.string,
  width: PropTypes.string,
  isTextWrapped: PropTypes.bool,
});

export const tableConfigShape = PropTypes.shape({
  attForDataId: PropTypes.string.isRequired,
  hasCheckbox: PropTypes.bool,
  checkboxWidth: PropTypes.string,
  columnsConfig: columnsConfigShape,
});