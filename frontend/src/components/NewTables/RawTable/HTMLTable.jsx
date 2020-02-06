import React, { Component } from 'react';
import './HTMLTable.css';

class HTMLTable extends Component {
  render() {
    return (
      <div className="table-wrapper">
        <table className="main-table">
          <thead className="main-table__header">
            <tr className="main-table__header__row">
              <th className="main-table__head-value">Os</th>
              <th className="main-table__head-value">Título</th>
              <th className="main-table__head-value">Status</th>
              <th className="main-table__head-value">Prazo Final</th>
              <th className="main-table__head-value">Localização</th>
            </tr>
          </thead>
          <tbody className="main-table__body">
            <tr className="main-table__body__row">
              <td className="main-table__data">001</td>
              <td className="main-table__data">Reparos de marcenaria</td>
              <td className="main-table__data">Cancelada</td>
              <td className="main-table__data">2019-01-20</td>
              <td className="main-table__data">Sala do SEMAC</td>
            </tr>
            <tr className="main-table__body__row">
              <td className="main-table__data">002</td>
              <td className="main-table__data">Troca de vidro</td>
              <td className="main-table__data">Negada</td>
              <td className="main-table__data">2020-01-02</td>
              <td className="main-table__data">Sala de reuniões</td>
            </tr>
            <tr className="main-table__body__row">
              <td className="main-table__data">003</td>
              <td className="main-table__data">Troca do piso</td>
              <td className="main-table__data">Execução</td>
              <td className="main-table__data">2019-12-12</td>
              <td className="main-table__data">Sala da SADCON</td>
            </tr>
          </tbody>
        </table>
      </div>
    );
  }
}

export default HTMLTable;