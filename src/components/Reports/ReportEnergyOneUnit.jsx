import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";
import { queryEnergyTable } from "../../utils/queryEnergyTable";


const rowNames = [
  { name: "Consumo", type: "main", unit: "", attr: "" },
  { name: "Ponta", type: "sub-1", unit: "", attr: "" },
  { name: "Consumo total", type: "sub-2", unit: "kWh", attr: "kwh" },
  { name: "Consumo ponta", type: "sub-2", unit: "kWh", attr: "kwhp" },
  { name: "Consumo fora de ponta", type: "sub-2", unit: "kWh", attr: "kwhf" },
  { name: "Demanda contratada (única - Verde)", type: "sub-2", unit: "kW", attr: "dc" },
  { name: "Demanda contratada ponta", type: "sub-2", unit: "kW", attr: "dcp" },
  { name: "Demanda contratada fora de ponta", type: "sub-2", unit: "kW", attr: "dcf" },
  { name: "Demanda medida ponta", type: "sub-2", unit: "kW", attr: "dmp" },
  { name: "Demanda medida fora de ponta", type: "sub-2", unit: "kW", attr: "dmf" },
  { name: "Demanda faturada ponta", type: "sub-2", unit: "kW", attr: "dfp" },
  { name: "Demanda faturada fora de ponta", type: "sub-2", unit: "kW", attr: "dff" },
  { name: "Valor da demanda faturada ponta", type: "sub-2", unit: "R$", attr: "vdfp" },
  { name: "Valor da demanda faturada fora de ponta", type: "sub-2", unit: "kW", attr: "vdff" },
  { name: "Valor da ultrapassagem de demanda ponta", type: "sub-2", unit: "R$", attr: "vudp" },
  { name: "Valor da ultrapassagem de demanda fora de ponta", type: "sub-2", unit: "kW", attr: "vudf" },
  { name: "EREX ponta", type: "sub-2", unit: "R$", attr: "erexp" },
  { name: "EREX fora de ponta", type: "sub-2", unit: "R$", attr: "erexf" },
  { name: "Juros, multas e atualização monetária", type: "sub-2", unit: "R$", attr: "jma" },
  { name: "Valor bruto", type: "sub-2", unit: "R$", attr: "vbru" },
  { name: "Tributos federais", type: "sub-2", unit: "R$", attr: "trib" },
  { name: "ICMS", type: "sub-2", unit: "R$", attr: "kwh" },
  { name: "CIP", type: "sub-2", unit: "R$", attr: "cip" },
  { name: "Base de cálculo", type: "sub-2", unit: "R$", attr: "basec" },
  { name: "Descontos e/ou compensações", type: "sub-2", unit: "R$", attr: "desc" },
  { name: "Valor líquido", type: "sub-2", unit: "R$", attr: "vliq" } 
]

class ReportEnergyOneUnit extends Component {
  constructor(props){
    super(props);
    this.state = {
      queryResponse: false
    };
  }

  componentWillMount(){
    queryEnergyTable(this.props.energyState, "EnergyTable").then(queryResponse => {
      console.log(queryResponse);
      this.setState({queryResponse: queryResponse});
    });
  }

  render() {
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" />{" "}
          <strong>Valores faturados</strong>
        </CardHeader>
        <CardBody>
        {!this.state.queryResponse ? "" : (
          <Table responsive size="sm">
            <thead>
              <tr className="header-table">
                <th />
                <th>{this.state.queryResponse.Items[0].aamm.toString()}</th>
                <th>Observações</th>
              </tr>
            </thead>
            
            <tbody>
              {rowNames.map((column, i) => (
                <tr className={column.type + "-table"}>
                  <th className={column.type + "-table"}>{column.name}</th>
                  <td className={column.type + "-table"}>
                    {column.unit === ""
                      ? ""
                      : column.unit === "R$"
                        ? "R$ " + this.state.queryResponse.Items[0][column.attr]
                        : this.state.queryResponse.Items[0][column.attr] + column.unit}
                  </td>
                  <td>Ok</td>
                </tr>
              ))}
          </tbody>
        </Table>)}
        </CardBody>
      </Card>
    );
  }
}

export default ReportEnergyOneUnit;
