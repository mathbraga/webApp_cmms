import React, { Component } from 'react';
import "./HTMLTable.css";

class TableItems extends Component {
  render() {
    const { thead, tbody } = this.props;
    return (
      <div className="table-container">
        {tbody.props.data.length !== 0 ?
          <table className="content-table">
            <thead className="thead-light">
              {thead}
            </thead>
            <tbody>
              {tbody}
            </tbody>
          </table>
          :
          <div className="no-items-table">
            <span className="no-items-description">Não há items para serem visualizados.</span>
          </div>
        }
      </div>);
  }
}

export default TableItems;