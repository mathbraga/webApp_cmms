import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";

// const rowNames = [
//   { name: "Nome", value: "Unidades de Apoio" },
//   { name: "Número de Identificação", value: "192.605-0" },
//   { name: "Contrato", value: "CT 112/2018" },
//   { name: "Endereço", value: "Via N2" },
//   { name: "Edíficios Alimentados", value: "Bloco 1, Bloco 2, Bloco 3" },
//   { name: "Tipo de Ligação", value: "Verde" },
//   { name: "Demanda Contratada Ponta", value: "110 kW" },
//   { name: "Demanda Contratada Ponta", value: "120 kW" }
// ];


class ReportInfoEnergy extends Component {
  // constructor(props){
  //   super(props);
  // }
  // state = {};
  render() {
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" />{" "}
          <strong>Informações Gerais</strong>
        </CardHeader>
        <CardBody>
          <Table responsive size="sm">
            <thead>
              <tr className="header-table">
                <th>Informações</th>
                <th />
              </tr>
            </thead>
            {/* <tbody>
              {rowNames.map(info => (
                <tr>
                  <th>{info.name}</th>
                  <td>{info.value}</td>
                </tr>
              ))}
            </tbody> */}

            <tbody>
              <tr>
                <th>Medidor: </th>
                <td>{this.props.result2.Items[0].idceb.S}</td>
              </tr>
              <tr>
                <th>Classe  Subclasse: </th>
                <td>{this.props.result2.Items[0].classe.S + " / " + this.props.result2.Items[0].subclasse.S}</td>
              </tr>
              <tr>
                <th>Grupo  Subgrupo: </th>
                <td>{this.props.result2.Items[0].grupo.S + " / " + this.props.result2.Items[0].subgrupo.S}</td>
              </tr>
              <tr>
                <th>Ligação: </th>
                <td>{this.props.result2.Items[0].lig.S}</td>
              </tr>
              <tr>
                <th>Contrato: </th>
                <td>{this.props.result2.Items[0].ct.S}</td>
              </tr>
              <tr>
                <th>Modalidade tarifária: </th>
                <td>{this.props.result2.Items[0].modtar.S}</td>
              </tr>
              <tr>
                <th>Edificações: </th> 
                {/* THIS INFORMATION MUST BE FIXED (USE LOOP TO SHOW ALL PLACES) */}
                <td>{this.props.result2.Items[0].locais.SS[0]}</td>
              </tr>
              <tr>
                <th>Observações: </th>
                <td>{this.props.result2.Items[0].obs.S}</td>
              </tr>

              
            </tbody>




          </Table>
        </CardBody>
      </Card>
    );
  }
}

export default ReportInfoEnergy;
