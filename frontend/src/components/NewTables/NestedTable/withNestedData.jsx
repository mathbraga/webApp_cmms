import React, { Component } from 'react';

function getChildren(result, dataTree, item, idAtt, nestingValue = 1) {
  if (dataTree[item[idAtt]]) {
    dataTree[item[idAtt]].forEach((child) => {
      result.data.push(child);
      result.childConfig.push({ nestingValue, hasChildren: Boolean(dataTree[child[idAtt]]) });
      getChildren(result, dataTree, child, idAtt, nestingValue + 1)
    })
  }
}

function prepareNestedData(dataTree, parentItems, idAtt) {
  const result = { data: [], childConfig: [] };
  parentItems.forEach((parent) => {
    dataTree[parent].forEach((item) => {
      result.data.push(item);
      result.childConfig.push({ nestingValue: 0, hasChildren: Boolean(dataTree[item[idAtt]]) });
      getChildren(result, dataTree, item, idAtt)
    })
  })
  return result;
}

export default function withNestedData(WrappedComponent) {
  class WithNestedData extends Component {
    render() {
      const { data, ...rest } = this.props;
      const nestedData = prepareNestedData(data, ["000"], "taskId")
      return (
        <WrappedComponent
          {...rest}
          data={nestedData}
        />
      );
    }
  }
  return WithNestedData;
}