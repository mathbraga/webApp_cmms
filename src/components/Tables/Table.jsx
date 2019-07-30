import React, { Component } from 'react';
import "./Table.css";

class TableItems extends Component {
  render() {
    const { thead, tbody } = this.props;
    return (
      <div className="table-container">
        <table className="content-table">
          <thead className="thead-light">
            {thead}
          </thead>
          <tbody>
            {tbody}
          </tbody>
        </table>
      </div>);
  }
}

export default TableItems;