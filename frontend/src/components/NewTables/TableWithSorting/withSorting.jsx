import React, { Component } from 'react';
import { sortBy } from "lodash";

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
      const { data, ...rest } = this.props;
      const { sortKey, isSortReverse } = this.state;
      const sortedList = sortKey ? sortBy(data, sortKey) : data;
      const reverseSortedList = (isSortReverse && sortKey) ? sortedList.reverse() : sortedList;
      return (
        <WrappedTable
          {...rest}
          onSort={this.onSort}
          activeSortKey={sortKey}
          isSortReverse={isSortReverse}
          data={reverseSortedList}
        />
      );
    }
  }

  return WithSorting;
}
