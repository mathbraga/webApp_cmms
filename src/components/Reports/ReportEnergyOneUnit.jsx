import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";

const rowNames = [
  { name: "Consumo", type: "main", unit: "" },
  { name: "Horário Ponta", type: "sub-1", unit: "" },
  { name: "Consumo Registrado", type: "sub-2", unit: "kWh" },
  { name: "Tarifa", type: "sub-2", unit: "R$/kWh" },
  { name: "Valor", type: "sub-2", unit: "R$" },
  { name: "Horário Fora de Ponta", type: "sub-1", unit: "" },
  { name: "Consumo Registrado", type: "sub-2", unit: "kWh" },
  { name: "Tarifa", type: "sub-2", unit: "R$/kWh" },
  { name: "Valor", type: "sub-2", unit: "R$" },
  { name: "Consumo Total", type: "sub-1", unit: "kWh" },
  { name: "Valor Total", type: "sub-1", unit: "R$" },
  { name: "Demanda", type: "main", unit: "" },
  { name: "Horário Ponta", type: "sub-1", unit: "" },
  { name: "Medido", type: "sub-2", unit: "kW" },
  { name: "Contratado", type: "sub-2", unit: "kW" },
  { name: "Faturado", type: "sub-2", unit: "kW" },
  { name: "Tarifa", type: "sub-2", unit: "R$/kW" },
  { name: "Valor Faturado", type: "sub-2", unit: "R$" },
  { name: "Ultrapassagem", type: "sub-2", unit: "R$" },
  { name: "Horário Fora de Ponta", type: "sub-1", unit: "" },
  { name: "Medido", type: "sub-2", unit: "kW" },
  { name: "Contratado", type: "sub-2", unit: "kW" },
  { name: "Faturado", type: "sub-2", unit: "kW" },
  { name: "Tarifa", type: "sub-2", unit: "R$/kW" },
  { name: "Valor Faturado", type: "sub-2", unit: "R$" },
  { name: "Ultrapassagem", type: "sub-2", unit: "R$" },
  { name: "Energia Reativa", type: "main", unit: "" },
  { name: "EREX P", type: "sub-2", unit: "R$" },
  { name: "EREX FP", type: "sub-2", unit: "R$" },
  { name: "Valor Total", type: "sub-1", unit: "R$" },
  { name: "Resumo dos Valores", type: "main", unit: "" },
  { name: "Energia", type: "sub-2", unit: "R$" },
  { name: "CIP", type: "sub-2", unit: "R$" },
  { name: "Descontos/Compensação", type: "sub-2", unit: "R$" },
  { name: "Juros/Multas", type: "sub-2", unit: "R$" },
  { name: "Tributos", type: "main", unit: "" },
  { name: "Base de Cáculo", type: "sub-2", unit: "R$" },
  { name: "Valor", type: "sub-2", unit: "R$" },
  { name: "Total Bruto", type: "main", unit: "R$" },
  { name: "Total Líquido", type: "main", unit: "R$" }
];

// const testValues = [
//   { name: "Consumo", value: "" },
//   { name: "Consumo P", value: "" },
//   { name: "Consumo Medido", value: "12.256" },
//   { name: "Tarifa", value: "0,456121" },
//   { name: "Valor", value: "1.256,24" },
//   { name: "Consumo FP", value: "" },
//   { name: "Consumo Medido", value: "53.256" },
//   { name: "Tarifa", value: "0,5461321" },
//   { name: "Valor", value: "3.526,25" },
//   { name: "Consumo Faturado", value: "65.562" },
//   { name: "Valor Total", value: "5.654,21" },
//   { name: "Demanda", value: "" },
//   { name: "Demanda P", value: "" },
//   { name: "Medido", value: "100" },
//   { name: "Contratado", value: "120" },
//   { name: "Faturado", value: "120" },
//   { name: "Tarifa", value: "0,56465" },
//   { name: "Valor Faturado", value: "1.250,55" },
//   { name: "Ultrapassagem", value: "0,00" },
//   { name: "Demanda FP", value: "" },
//   { name: "Medido", value: "100" },
//   { name: "Contratado", value: "120" },
//   { name: "Faturado", value: "120" },
//   { name: "Tarifa", value: "0,564654" },
//   { name: "Valor Faturado", value: "1.350,50" },
//   { name: "Ultrapassagem", value: "0,00" },
//   { name: "Energia Reativa", value: "" },
//   { name: "EREX P", value: "0,00" },
//   { name: "EREX FP", value: "0,00" },
//   { name: "Valor", value: "0,00" },
//   { name: "Resumo dos Valores", value: "" },
//   { name: "Energia", value: "6.562,22" },
//   { name: "CIP", value: "712,55" },
//   { name: "Descontos/Compensação", value: "0,00" },
//   { name: "Juros/Multas", value: "0,00" },
//   { name: "Tributos", value: "" },
//   { name: "Base de Cáculo", value: "2.054,00" },
//   { name: "Valor", value: "4.561,25" },
//   { name: "Total Bruto", value: "6.545,24" },
//   { name: "Total Líquido", value: "5.654,25" }
// ];


const testValues = [
  { name: "Consumo" },
  { name: "Consumo P" },
  { name: "Consumo Medido" },
  { name: "Tarifa" },
  { name: "Valor" },
  { name: "Consumo FP" },
  { name: "Consumo Medido" },
  { name: "Tarifa" },
  { name: "Valor" },
  { name: "Consumo Faturado" },
  { name: "Valor Total" },
  { name: "Demanda" },
  { name: "Demanda P" },
  { name: "Medido" },
  { name: "Contratado" },
  { name: "Faturado" },
  { name: "Tarifa" },
  { name: "Valor Faturado" },
  { name: "Ultrapassagem" },
  { name: "Demanda FP" },
  { name: "Medido" },
  { name: "Contratado" },
  { name: "Faturado" },
  { name: "Tarifa" },
  { name: "Valor Faturado" },
  { name: "Ultrapassagem" },
  { name: "Energia Reativa" },
  { name: "EREX P" },
  { name: "EREX FP" },
  { name: "Valor" },
  { name: "Resumo dos Valores" },
  { name: "Energia" },
  { name: "CIP" },
  { name: "Descontos/Compensação" },
  { name: "Juros/Multas" },
  { name: "Tributos" },
  { name: "Base de Cáculo" },
  { name: "Valor" },
  { name: "Total Bruto" },
  { name: "Total Líquido" }
];

class ReportEnergyOneUnit extends Component {
  constructor(props){
    super(props);
  }
  render() {
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" />{" "}
          <strong>Valores faturados}</strong>
        </CardHeader>
        <CardBody>
          <Table responsive size="sm">
            <thead>
              <tr className="header-table">
                <th />
                <th>{this.props.result1.Items[0].aamm.toString()}</th>
                {/* <th>Jan/2017</th>
                <th>Média</th> */}
                <th>Observações</th>
              </tr>
            </thead>
            {/* <tbody>
              {rowNames.map((column, i) => (
                <tr className={column.type + "-table"}>
                  <th className={column.type + "-table"}>{column.name}</th>
                  <td className={column.type + "-table"}>
                    {column.unit === "R$"
                      ? "R$ " + testValues[i].value
                      : testValues[i].value + " " + column.unit}
                  </td>
                  <td className={column.type + "-table"}>
                    {column.unit === "R$"
                      ? "R$ " + testValues[i].value
                      : testValues[i].value + " " + column.unit}
                  </td>
                  <td className={column.type + "-table"}>
                    {column.unit === "R$"
                      ? "R$ " + testValues[i].value
                      : testValues[i].value + " " + column.unit}
                  </td>
                  <td>Ok</td>
                </tr>
              ))}
            </tbody> */}

            <tbody>
              <tr className="main-table">
                <th className="sub-1-table">Resumo</th>
                <td className="sub-2-table">Base de cálculo</td>
                <td className="sub-2-table">{this.props.result1.Items[0].basec.toString()}</td>
                <td>Ok</td>
                </tr>
            </tbody>


          </Table>
        </CardBody>
      </Card>
    );
  }
}

export default ReportEnergyOneUnit;
