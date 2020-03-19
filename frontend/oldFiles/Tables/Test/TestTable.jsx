import React, { Component } from 'react';
import './TestTable.css';

class TestTable extends Component {
  render() {
    return (
      <table className="content-table-test">
        <thead>
          <tr>
            <th>Id</th>
            <th>Firstname</th>
            <th>Lastname</th>
            <th>Email</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>001</td>
            <td>Pedro</td>
            <td>Serafim</td>
            <td>serafasdfasdfsda@gmail.com</td>
          </tr>
          <tr>
            <td>002</td>
            <td>Thiago</td>
            <td>Silva</td>
            <td>tiago@gmail.com</td>
          </tr>
          <tr>
            <td>003</td>
            <td>Rafael</td>
            <td>Nunes</td>
            <td>rafael@gmail.com</td>
          </tr>
        </tbody>
      </table>
    );
  }
}

export default TestTable;