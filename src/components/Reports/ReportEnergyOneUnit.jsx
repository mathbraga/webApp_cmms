import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";

const rowNames = [
  { name: "Consumo", type: "main", unit: "", attr: "" },
  { name: "Horário Ponta", type: "sub-1", unit: "", attr: "" },
  { name: "Consumo Registrado", type: "sub-2", unit: "kWh", attr: "kwhp" },
  { name: "Tarifa", type: "sub-2", unit: "R$/kWh", attr: "" },
  { name: "Valor", type: "sub-2", unit: "R$", attr: "" },
  { name: "Horário Fora de Ponta", type: "sub-1", unit: "", attr: "" },
  { name: "Consumo Registrado", type: "sub-2", unit: "kWh", attr: "kwhf" },
  { name: "Tarifa", type: "sub-2", unit: "R$/kWh", attr: "" },
  { name: "Valor", type: "sub-2", unit: "R$", attr: "" },
  { name: "Consumo Total", type: "sub-1", unit: "kWh", attr: "kwh" },
  { name: "Valor Total", type: "sub-1", unit: "R$", attr: "" },
  { name: "Demanda", type: "main", unit: "", attr: "" },
  { name: "Horário Ponta", type: "sub-1", unit: "", attr: "" },
  { name: "Medido", type: "sub-2", unit: "kW", attr: "dmp" },
  { name: "Contratado", type: "sub-2", unit: "kW", attr: "dcp" },
  { name: "Faturado", type: "sub-2", unit: "kW", attr: "dfp" },
  { name: "Tarifa", type: "sub-2", unit: "R$/kW", attr: "" },
  { name: "Valor Faturado", type: "sub-2", unit: "R$", attr: "vdfp" },
  { name: "Ultrapassagem", type: "sub-2", unit: "R$", attr: "vudp" },
  { name: "Horário Fora de Ponta", type: "sub-1", unit: "", attr: "" },
  { name: "Medido", type: "sub-2", unit: "kW", attr: "dmf" },
  { name: "Contratado", type: "sub-2", unit: "kW", attr: "dcf" },
  { name: "Faturado", type: "sub-2", unit: "kW", attr: "dff" },
  { name: "Tarifa", type: "sub-2", unit: "R$/kW", attr: "" },
  { name: "Valor Faturado", type: "sub-2", unit: "R$", attr: "vdff" },
  { name: "Ultrapassagem", type: "sub-2", unit: "R$", attr: "vudf" },
  { name: "Energia Reativa", type: "main", unit: "", attr: "" },
  { name: "EREX P", type: "sub-2", unit: "R$", attr: "erexp" },
  { name: "EREX FP", type: "sub-2", unit: "R$", attr: "erexf" },
  { name: "Valor Total", type: "sub-1", unit: "R$", attr: "" },
  { name: "Tributos", type: "main", unit: "", attr: "" },
  { name: "Base de Cáculo", type: "sub-2", unit: "R$", attr: "basec" },
  { name: "Valor", type: "sub-2", unit: "R$", attr: "trib" },
  { name: "Resumo dos Valores", type: "main", unit: "", attr: "" },
  { name: "Energia", type: "sub-2", unit: "R$", attr: "" },
  { name: "CIP", type: "sub-2", unit: "R$", attr: "cip" },
  { name: "Descontos/Compensação", type: "sub-2", unit: "R$", attr: "desc" },
  { name: "Juros/Multas", type: "sub-2", unit: "R$", attr: "jma" },
  { name: "Total Bruto", type: "main", unit: "R$", attr: "vbru" },
  { name: "Total Líquido", type: "main", unit: "R$", attr: "vliq" }
];

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
                <th>{this.props.dateString}</th>
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
                      : isNaN(this.props.data[column.attr])
                      ? "-"
                      : column.unit === "R$"
                      ? "R$ " + this.formatNumber(this.props.data[column.attr])
                      : this.formatNumber(this.props.data[column.attr]) +
                        " " +
                        column.unit}
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
