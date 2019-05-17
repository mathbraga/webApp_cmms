import React, { Component } from "react";
import { Table } from "reactstrap";
import ReportCard from "../Cards/ReportCard";
import queryLastBills from "../../utils/consumptionMonitor/queryLastBills";
import { transformDateString } from "../../utils/consumptionMonitor/transformDateString";
import formatNumber from "../../utils/consumptionMonitor/formatText";
// import { rowNames } from "./ReportOneUnit-Config";

class ReportOneUnit extends Component {
  constructor(props) {
    super(props);

    this.rowNamesBill = this.props.rowNamesBill;

    this.state = {
      typeOfComparison: "lastMonth",
      comparisonResponseList: false
    };
  }

  componentDidMount() {
    queryLastBills(
      this.props.dbObject,
      this.props.tableName,
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
        this.rowNamesBill.forEach(column => {
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
    // const {
    //   rowNamesBill
    // } = this.props;

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
            {this.rowNamesBill.map((column, i) =>
              column.showInTypes.includes(this.props.data.tipo) ||
              column.showInTypes.includes(resultCompareObject.tipo) ? (
                <tr key={"1-" + i.toString()} className={column.type + "-table"}>
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
                <tr key={"1-" + i.toString()} className={column.type + "-table"}></tr>
              )
            )}
          </tbody>
        </Table>
      </ReportCard>
    );
  }
}

export default ReportOneUnit;
