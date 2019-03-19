import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";

const rowNames = [
  { name: "Consumo", type: "main", unit: "", attr: "" },
  { name: "Ponta", type: "sub-1", unit: "", attr: "" },
  { name: "Consumo total", type: "sub-2", unit: "kWh", attr: "kwh" },
  { name: "Consumo ponta", type: "sub-2", unit: "kWh", attr: "kwhp" },
  { name: "Consumo fora de ponta", type: "sub-2", unit: "kWh", attr: "kwhf" },
  {
    name: "Demanda contratada (única - Verde)",
    type: "sub-2",
    unit: "kW",
    attr: "dc"
  },
  { name: "Demanda contratada ponta", type: "sub-2", unit: "kW", attr: "dcp" },
  {
    name: "Demanda contratada fora de ponta",
    type: "sub-2",
    unit: "kW",
    attr: "dcf"
  },
  { name: "Demanda medida ponta", type: "sub-2", unit: "kW", attr: "dmp" },
  {
    name: "Demanda medida fora de ponta",
    type: "sub-2",
    unit: "kW",
    attr: "dmf"
  },
  { name: "Demanda faturada ponta", type: "sub-2", unit: "kW", attr: "dfp" },
  {
    name: "Demanda faturada fora de ponta",
    type: "sub-2",
    unit: "kW",
    attr: "dff"
  },
  {
    name: "Valor da demanda faturada ponta",
    type: "sub-2",
    unit: "R$",
    attr: "vdfp"
  },
  {
    name: "Valor da demanda faturada fora de ponta",
    type: "sub-2",
    unit: "kW",
    attr: "vdff"
  },
  {
    name: "Valor da ultrapassagem de demanda ponta",
    type: "sub-2",
    unit: "R$",
    attr: "vudp"
  },
  {
    name: "Valor da ultrapassagem de demanda fora de ponta",
    type: "sub-2",
    unit: "kW",
    attr: "vudf"
  },
  { name: "EREX ponta", type: "sub-2", unit: "R$", attr: "erexp" },
  { name: "EREX fora de ponta", type: "sub-2", unit: "R$", attr: "erexf" },
  {
    name: "Juros, multas e atualização monetária",
    type: "sub-2",
    unit: "R$",
    attr: "jma"
  },
  { name: "Valor bruto", type: "sub-2", unit: "R$", attr: "vbru" },
  { name: "Tributos federais", type: "sub-2", unit: "R$", attr: "trib" },
  { name: "ICMS", type: "sub-2", unit: "R$", attr: "kwh" },
  { name: "CIP", type: "sub-2", unit: "R$", attr: "cip" },
  { name: "Base de cálculo", type: "sub-2", unit: "R$", attr: "basec" },
  {
    name: "Descontos e/ou compensações",
    type: "sub-2",
    unit: "R$",
    attr: "desc"
  },
  { name: "Valor líquido", type: "sub-2", unit: "R$", attr: "vliq" }
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
//   { name: "Base de Cáculo", value: "5.555,21" },
//   { name: "Valor", value: "4.561,25" },
//   { name: "Total Bruto", value: "6.545,24" },
//   { name: "Total Líquido", value: "5.654,25" }
// ];

class ReportEnergyOneUnit extends Component {
  formatNumber(number) {
    return number.toLocaleString("pt-BR", { maximumFractionDigits: 2 });
  }
  render() {
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" />{" "}
          <strong>Valores faturados</strong>
        </CardHeader>
        <CardBody>
          <Table responsive size="sm">
            <thead>
              <tr className="header-table">
                <th />
                <th>{this.props.data.aamm.toString()}</th>
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
                      ? "R$ " + this.props.data[column.attr]
                      : this.props.data[column.attr] + " " + column.unit}
                  </td>
                  <td>Ok</td>
                </tr>
              ))}
            </tbody>
          </Table>
        </CardBody>
      </Card>
    );
  }
}

export default ReportEnergyOneUnit;
