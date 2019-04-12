import React, { Component } from "react";
import { Table } from "reactstrap";
import { queryLastBills } from "../../utils/queryLastBills";
import { transformDateString } from "../../utils/transformDateString";
import ReportCard from "../Cards/ReportCard";
import { formatNumber } from "../../utils/formatText";

const rowNames = [
  {
    name: "Consumo",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Horário ponta",
    type: "sub-1",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "Consumo registrado",
    type: "hover-line sub-2",
    unit: "kWh",
    attr: "kwhp",
    var: true,
    mean: true,
    showInTypes: [1, 2]
  },
  {
    name: "Tarifa",
    type: "hover-line sub-2",
    unit: "R$/kWh",
    attr: "",
    var: true,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "Valor",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "",
    var: true,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "Horário fora de ponta",
    type: "sub-1",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "Consumo registrado",
    type: "hover-line sub-2",
    unit: "kWh",
    attr: "kwhf",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Consumo faturado",
    type: "hover-line sub-2",
    unit: "kWh",
    attr: "confat",
    var: true,
    mean: true,
    showInTypes: [0]
  },
  {
    name: "Tarifa",
    type: "hover-line sub-2",
    unit: "R$/kWh",
    attr: "",
    var: true,
    mean: false,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Valor",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "",
    var: true,
    mean: false,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Consumo total",
    type: "hover-line sub-1",
    unit: "kWh",
    attr: "kwh",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Valor total",
    type: "hover-line sub-1",
    unit: "R$",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Demanda",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "Horário ponta",
    type: "sub-1",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    justBlue: true,
    showInTypes: [2]
  },
  {
    name: "Medido",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dmp",
    var: true,
    mean: true,
    justBlue: true,
    showInTypes: [2]
  },
  {
    name: "Contratado",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dcp",
    var: false,
    mean: false,
    justBlue: true,
    showInTypes: [2]
  },
  {
    name: "Faturado",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dfp",
    var: true,
    mean: true,
    justBlue: true,
    showInTypes: [2]
  },
  {
    name: "Tarifa",
    type: "hover-line sub-2",
    unit: "R$/kW",
    attr: "",
    var: true,
    mean: false,
    justBlue: true,
    showInTypes: [2]
  },
  {
    name: "Valor faturado",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "vdfp",
    var: true,
    mean: true,
    justBlue: true,
    showInTypes: [2]
  },
  {
    name: "Ultrapassagem",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "vudp",
    var: true,
    justBlue: true,
    showInTypes: [2]
  },
  {
    name: "Horário fora de ponta",
    type: "sub-1",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    justBlue: true,
    showInTypes: [2]
  },
  {
    name: "Medido",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dmf",
    var: true,
    mean: true,
    showInTypes: [1, 2]
  },
  {
    name: "Contratado",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dcf",
    var: false,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "Faturado",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dff",
    var: true,
    mean: true,
    showInTypes: [1, 2]
  },
  {
    name: "Tarifa",
    type: "hover-line sub-2",
    unit: "R$/kW",
    attr: "",
    var: true,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "Valor faturado",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "vdff",
    var: true,
    mean: true,
    showInTypes: [1, 2]
  },
  {
    name: "Ultrapassagem",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "vudf",
    var: true,
    mean: true,
    showInTypes: [1, 2]
  },
  {
    name: "Energia reativa",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "EREX P",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "verexp",
    var: true,
    mean: true,
    showInTypes: [1, 2]
  },
  {
    name: "EREX FP",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "verexf",
    var: true,
    mean: true,
    showInTypes: [1, 2]
  },
  {
    name: "Valor total",
    type: "hover-line sub-1",
    unit: "R$",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [1, 2]
  },
  {
    name: "Tributos",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Base de cáculo",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "basec",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Valor total",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "trib",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Resumo dos valores",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Energia",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "",
    var: true,
    mean: false,
    showInTypes: [0, 1, 2]
  },
  {
    name: "CIP",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "cip",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Descontos/Compensação",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "desc",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Juros/Multas",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "jma",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Total bruto",
    type: "hover-line main",
    unit: "R$",
    attr: "vbru",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  },
  {
    name: "Total líquido",
    type: "hover-line main",
    unit: "R$",
    attr: "vliq",
    var: true,
    mean: true,
    showInTypes: [0, 1, 2]
  }
];

class ReportEnergyOneUnit extends Component {
  constructor(props) {
    super(props);
    this.state = {
      typeOfComparison: "lastMonth",
      comparisonResponseList: false
    };
  }

  componentDidMount() {
    queryLastBills(
      this.props.dbObject,
      this.props.consumer,
      this.props.date - 100,
      this.props.date
    ).then(lastItems => {
      this.setState({
        comparisonResponseList: lastItems.Items
      });
    });
  }

  returnChangeComparisonObject() {
    let result = false;
    let dateRequired = this.props.date;
    switch (this.state.typeOfComparison) {
      case "lastMonth":
        this.state.comparisonResponseList.forEach(item => {
          dateRequired =
            this.props.date % 100 === 1
              ? this.props.date - 100 + 11
              : this.props.date - 1;
          if (dateRequired === item.aamm) {
            result = item;
          }
        });
        break;
      case "yearAgo":
        this.state.comparisonResponseList.forEach(item => {
          dateRequired = this.props.date - 100;
          if (dateRequired === item.aamm) result = item;
        });
        break;
      default:
        result = {};
        rowNames.forEach(column => {
          let size = 0;
          if (column.attr) {
            this.state.comparisonResponseList.forEach(item => {
              if (item[column.attr] > 0) {
                result[column.attr]
                  ? (result[column.attr] += item[column.attr])
                  : (result[column.attr] = item[column.attr]);
                size += 1;
              }
            });
            result[column.attr] /= size;
          }
        });
        break;
    }
    return { result: result, dateRequired: dateRequired };
  }

  handleChangeComparison = type => {
    this.setState({ typeOfComparison: type });
  };

  render() {
    const compareObject =
      this.state.comparisonResponseList && this.returnChangeComparisonObject();
    const resultCompareObject = compareObject && compareObject.result;
    const dateCompareObject = compareObject && compareObject.dateRequired;

    return (
      <ReportCard
        title={"Fatura detalhada"}
        titleColSize={5}
        subtitle={"Mês de referência:"}
        subvalue={this.props.dateString}
        dropdown
        dropdownTitle={"Comparar com:"}
        dropdownItems={{
          lastMonth: "Mês anterior",
          yearAgo: "Ano anterior",
          median: "Média (últimos 12 meses)"
        }}
        showCalcResult={this.handleChangeComparison}
        resultID={this.state.typeOfComparison}
      >
        <Table responsive size="sm">
          <thead>
            <tr className="header-table">
              <th />
              <th>{this.props.dateString}</th>
              <th>
                {this.state.typeOfComparison === "median"
                  ? "Média (12 meses)"
                  : transformDateString(dateCompareObject)}
              </th>
              <th>Variação</th>
            </tr>
          </thead>
          <tbody>
            {rowNames.map((column, i) =>
              column.showInTypes.includes(this.props.data.tipo) ||
              column.showInTypes.includes(resultCompareObject.tipo) ? (
                <tr className={column.type + "-table"}>
                  <th className={column.type + "-table"}>{column.name}</th>
                  <td className={column.type + "-table"}>
                    {column.unit === ""
                      ? ""
                      : isNaN(this.props.data[column.attr]) ||
                        this.props.data[column.attr] === 0
                      ? "-"
                      : column.unit === "R$"
                      ? "R$ " + formatNumber(this.props.data[column.attr], 2)
                      : formatNumber(this.props.data[column.attr], 0) +
                        " " +
                        column.unit}
                  </td>
                  <td className={column.type + "-table"}>
                    {column.unit === ""
                      ? ""
                      : isNaN(resultCompareObject[column.attr]) ||
                        resultCompareObject[column.attr] === 0
                      ? "-"
                      : column.unit === "R$"
                      ? "R$ " +
                        formatNumber(resultCompareObject[column.attr], 2)
                      : formatNumber(resultCompareObject[column.attr], 0) +
                        " " +
                        column.unit}
                  </td>
                  <td>
                    {!column.var
                      ? ""
                      : isNaN(this.props.data[column.attr]) ||
                        isNaN(resultCompareObject[column.attr]) ||
                        !this.props.data[column.attr] ||
                        !resultCompareObject[column.attr] ||
                        this.props.data[column.attr] ==
                          resultCompareObject[column.attr]
                      ? "-"
                      : formatNumber(
                          ((this.props.data[column.attr] -
                            resultCompareObject[column.attr]) /
                            resultCompareObject[column.attr]) *
                            100,
                          2
                        ) + " %"}
                  </td>
                </tr>
              ) : (
                ""
              )
            )}
          </tbody>
        </Table>
      </ReportCard>
    );
  }
}

export default ReportEnergyOneUnit;
