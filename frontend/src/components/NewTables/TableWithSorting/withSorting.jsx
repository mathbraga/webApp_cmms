import React, { Component } from 'react';
import { sortBy } from "lodash";

function sortList(data, sortKey, isSortReverse, isDataTree) {
  if (isDataTree) {
    let sortedList = {};
    if (sortKey) {
      Object.keys(data).forEach((parent) => sortedList[parent] = sortBy(data[parent], sortKey));
      if (isSortReverse) {
        Object.keys(data).forEach((parent) => sortedList[parent].reverse());
      }
    } else {
      sortedList = data;
    }
    return sortedList;
  }

  // It is not DataTree
  const sortedList = sortKey ? sortBy(data, sortKey) : data;
  const reverseSortedList = (isSortReverse && sortKey) ? sortedList.reverse() : sortedList;

  return reverseSortedList;
}


export default function withSorting(WrappedTable) {

  class WithSorting extends Component {
    constructor(props) {
      super(props);
      this.state = {
        sortKey: null,
        isSortReverse: false
      }

      this.onSort = this.onSort.bind(this);
    }

    onSort(sortKey) {
      const isSortReverse =
        this.state.sortKey === sortKey && !this.state.isSortReverse;
      this.setState({ sortKey, isSortReverse });
    }

    render() {
      const { data, isDataTree, ...rest } = this.props;
      const { sortKey, isSortReverse } = this.state;

      const sortedList = sortList(data, sortKey, isSortReverse, isDataTree);

      return (
        <WrappedTable
          {...rest}
          onSort={this.onSort}
          activeSortKey={sortKey}
          isSortReverse={isSortReverse}
          data={sortedList}
          isDataTree={isDataTree}
        />
      );
    }
  }

  return WithSorting;
}
