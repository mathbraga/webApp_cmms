import PropTypes from 'prop-types';

export const alignShape = PropTypes.oneOf(['center', 'justify']);

export const selectedDataShape = PropTypes.objectOf(PropTypes.bool);

export const columnsConfigShape = PropTypes.shape({
  columnId: PropTypes.string.isRequired,
  columnName: PropTypes.string.isRequired,
  width: PropTypes.string,
  align: PropTypes.string,
  isTextWrapped: PropTypes.bool,
  idForValues: PropTypes.arrayOf(PropTypes.string).isRequired,
});

export const tableConfigShape = PropTypes.shape({
  attForDataId: PropTypes.string.isRequired,
  hasCheckbox: PropTypes.bool,
  checkboxWidth: PropTypes.string,
  isDataTree: PropTypes.bool,
  idForNestedTable: PropTypes.string.isRequired,
  isItemClickable: PropTypes.bool,
  itemPathWithoutID: PropTypes.string,
  columnsConfig: columnsConfigShape,
});
