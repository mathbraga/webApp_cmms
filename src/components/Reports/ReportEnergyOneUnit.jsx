import React, { Component } from "react";
import { Table } from "reactstrap";
import { queryLastBills } from "../../utils/queryLastBills";
import { transformDateString } from "../../utils/transformDateString";
import ReportCard from "../Cards/ReportCard";

const rowNames = [
  {
    name: "Consumo",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "Horário ponta",
    type: "sub-1",
    unit: "",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "Consumo registrado",
    type: "hover-line sub-2",
    unit: "kWh",
    attr: "kwhp",
    var: true,
    mean: true
  },
  {
    name: "Tarifa",
    type: "hover-line sub-2",
    unit: "R$/kWh",
    attr: "",
    var: true,
    mean: false
  },
  {
    name: "Valor",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "",
    var: true,
    mean: false
  },
  {
    name: "Horário fora de ponta",
    type: "sub-1",
    unit: "",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "Consumo registrado",
    type: "hover-line sub-2",
    unit: "kWh",
    attr: "kwhf",
    var: true,
    mean: true
  },
  {
    name: "Tarifa",
    type: "hover-line sub-2",
    unit: "R$/kWh",
    attr: "",
    var: true,
    mean: false
  },
  {
    name: "Valor",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "",
    var: true,
    mean: false
  },
  {
    name: "Consumo total",
    type: "hover-line sub-1",
    unit: "kWh",
    attr: "kwh",
    var: true,
    mean: true
  },
  {
    name: "Valor total",
    type: "hover-line sub-1",
    unit: "R$",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "Demanda",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "Horário ponta",
    type: "sub-1",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    justBlue: true
  },
  {
    name: "Medido",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dmp",
    var: true,
    mean: true,
    justBlue: true
  },
  {
    name: "Contratado",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dcp",
    var: false,
    mean: false,
    justBlue: true
  },
  {
    name: "Faturado",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dfp",
    var: true,
    mean: true,
    justBlue: true
  },
  {
    name: "Tarifa",
    type: "hover-line sub-2",
    unit: "R$/kW",
    attr: "",
    var: true,
    mean: false,
    justBlue: true
  },
  {
    name: "Valor faturado",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "vdfp",
    var: true,
    mean: true,
    justBlue: true
  },
  {
    name: "Ultrapassagem",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "vudp",
    var: true,
    justBlue: true
  },
  {
    name: "Horário fora de ponta",
    type: "sub-1",
    unit: "",
    attr: "",
    var: false,
    mean: false,
    justBlue: true
  },
  {
    name: "Medido",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dmf",
    var: true,
    mean: true
  },
  {
    name: "Contratado",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dcf",
    var: false,
    mean: false
  },
  {
    name: "Faturado",
    type: "hover-line sub-2",
    unit: "kW",
    attr: "dff",
    var: true,
    mean: true
  },
  {
    name: "Tarifa",
    type: "hover-line sub-2",
    unit: "R$/kW",
    attr: "",
    var: true,
    mean: false
  },
  {
    name: "Valor faturado",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "vdff",
    var: true,
    mean: true
  },
  {
    name: "Ultrapassagem",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "vudf",
    var: true,
    mean: true
  },
  {
    name: "Energia reativa",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "EREX P",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "erexp",
    var: true,
    mean: true
  },
  {
    name: "EREX FP",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "erexf",
    var: true,
    mean: true
  },
  {
    name: "Valor total",
    type: "hover-line sub-1",
    unit: "R$",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "Tributos",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "Base de cáculo",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "basec",
    var: true,
    mean: true
  },
  {
    name: "Valor total",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "trib",
    var: true,
    mean: true
  },
  {
    name: "Resumo dos valores",
    type: "main",
    unit: "",
    attr: "",
    var: false,
    mean: false
  },
  {
    name: "Energia",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "",
    var: true,
    mean: false
  },
  {
    name: "CIP",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "cip",
    var: true,
    mean: true
  },
  {
    name: "Descontos/Compensação",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "desc",
    var: true,
    mean: true
  },
  {
    name: "Juros/Multas",
    type: "hover-line sub-2",
    unit: "R$",
    attr: "jma",
    var: true,
    mean: true
  },
  {
    name: "Total bruto",
    type: "hover-line main",
    unit: "R$",
    attr: "vbru",
    var: true,
    mean: true
  },
  {
    name: "Total líquido",
    type: "hover-line main",
    unit: "R$",
    attr: "vliq",
    var: true,
    mean: true
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
      console.log("oneUnitReport:");
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
              result[column.attr]
                ? (result[column.attr] += item[column.attr])
                : (result[column.attr] = item[column.attr]);
              size += 1;
            });
            result[column.attr] /= size;
          }
          console.log("Result:");
          console.log(size);
          console.log(result);
        });
        break;
    }
    return { result: result, dateRequired: dateRequired };
  }

  formatNumber(number) {
    return number.toLocaleString("pt-BR", { maximumFractionDigits: 2 });
  }

  handleChangeComparison = type => {
    this.setState({ typeOfComparison: type });
    console.log("Comparison List:");
    console.log(this.state.comparisonResponseList);
    console.log(type);
  };

  render() {
    const compareObject =
      this.state.comparisonResponseList && this.returnChangeComparisonObject();
    const resultCompareObject = compareObject && compareObject.result;
    const dateCompareObject = compareObject && compareObject.dateRequired;
    console.log("CompareOjbect:");
    console.log(resultCompareObject);
    console.log(dateCompareObject);

    if (resultCompareObject && resultCompareObject.tipo === 1) {
      resultCompareObject.dcf = resultCompareObject.dc;
      resultCompareObject.dcp = 0;
    }

    return (
      <ReportCard
        title={"Fatura Detalhada"}
        titleColSize={5}
        subtitle={"Mês de Referência:"}
        subvalue={this.props.dateString}
        dropdown
        dropdownTitle={"Comparar com:"}
        dropdownItems={{
          lastMonth: "Último mês",
          yearAgo: "Mesmo período (12 meses atrás)",
          median: "Média (12 meses)"
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
              <th>Variações</th>
            </tr>
          </thead>
          <tbody>
            {rowNames.map((column, i) =>
              !column.justBlue ||
              this.props.data.tipo === 2 ||
              resultCompareObject.tipo === 2 ? (
                <tr className={column.type + "-table"}>
                  <th className={column.type + "-table"}>{column.name}</th>
                  <td className={column.type + "-table"}>
                    {column.unit === ""
                      ? ""
                      : isNaN(this.props.data[column.attr]) ||
                        this.props.data[column.attr] === 0
                      ? "-"
                      : column.unit === "R$"
                      ? "R$ " + this.formatNumber(this.props.data[column.attr])
                      : this.formatNumber(this.props.data[column.attr]) +
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
                        this.formatNumber(resultCompareObject[column.attr])
                      : this.formatNumber(resultCompareObject[column.attr]) +
                        " " +
                        column.unit}
                  </td>
                  <td>
                    {!column.var
                      ? ""
                      : isNaN(this.props.data[column.attr]) ||
                        isNaN(resultCompareObject[column.attr]) ||
                        !this.props.data[column.attr] ||
                        !resultCompareObject[column.attr]
                      ? "-"
                      : this.formatNumber(
                          ((this.props.data[column.attr] -
                            resultCompareObject[column.attr]) /
                            resultCompareObject[column.attr]) *
                            100
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
