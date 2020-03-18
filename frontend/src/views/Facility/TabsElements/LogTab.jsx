import React, { Component } from 'react';
import { Container, Row, Col, Card, CardBody, } from "reactstrap";

import "./LogTab.css";
import LogTabData from './TempFakeData/LogTabFakeData';
import initials from './TempFakeData/initialsSeparator';

class LogTab extends Component {
  state = {}
  render() {
    return (
        <div>
          <div className="history__main">
            <div className="history__date">11/03/2020 <span className="text-muted">Quarta-feira</span></div>
            {
              LogTabData.map((item) => 
              <div className="history__items">
                <div className="history__icon"><span className="history__initials">{initials(item.name)}</span></div>
                <div className="history__occurence">
                  <div className="history__creator">{item.name}</div>
                  <div className="history__description">atualizou o ativo <span>CASF</span></div>
                  <ul>
                    <li>Nome do ativo alterado para "Novo nome"</li>
                    <li>Valor do ativo alterado para "Novo valor"</li>
                  </ul>
                  <div className="text-muted">Atualizado às {item.time}</div>
                </div>
              </div>
              )
            }
          </div>
        </div>
    );
  }
}

export default LogTab;