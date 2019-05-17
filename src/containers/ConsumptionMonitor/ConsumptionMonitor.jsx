import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import handleDates from "../../utils/consumptionMonitor/handleDates";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import handleSearch from "../../utils/consumptionMonitor/handleSearch";
import getAllMeters from "../../utils/consumptionMonitor/getAllMeters";
import { Route, Switch } from "react-router-dom";
import ResultOM from "./ResultOM";
import ResultOP from "./ResultOP";
import ResultAM from "./ResultAM";
import ResultAP from "./ResultAP";

class ConsumptionMonitor extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tableName: this.props.tableName,
      tableNameMeters: this.props.tableNameMeters,
      meterType: this.props.meterType,
      defaultMeter: this.props.meterType + "99",
      nonEmptyMeters: [],
      meters: [],
      dbObject: initializeDynamoDB(),
      initialDate: "",
      finalDate: "",
      chosenMeter: this.props.meterType + "99",
      oneMonth: false,
      error: false,
      queryResponse: false,
      queryResponseAll: false,
      chartConfigs: {},
      showResult: false,
      newLocation: this.props.location
    };
  }

  componentDidMount() {
    getAllMeters(this.state.dbObject, this.state.tableNameMeters, this.state.meterType).then(meters => {
      this.setState({
        meters: meters
      });
    });
  }

  handleChangeOnDates = handleDates.bind(this);
  
  handleQuery = event => {
    handleSearch(this.state.initialDate, this.state.finalDate, this.state.oneMonth, this.state.chosenMeter, this.state.meterType, this.state.meters, this.state.dbObject, this.state.tableName).then(newState => {
      this.setState(newState);
    }).catch(() => {
      alert("Houve um problema. Por favor, escolha novos parâmetros de pesquisa.");
    }); 
  }

  handleOneMonth = event => {
    this.setState({
      oneMonth: event.target.checked
    });
  };

  handleMeterChange = event => {
    this.setState({
      chosenMeter: event.target.value
    });
  };

  showFormDates = event => {
    this.setState((prevState, props) => ({
      showResult: false,
      initialDate: prevState.initialDate,
      finalDate: prevState.finalDate,
      chosenMeter: prevState.defaultMeter,
      oneMonth: prevState.oneMonth,
      newLocation: this.props.location
    }));
  };

  render() {
    return (
      <React.Fragment>
        <Switch location={this.state.newLocation}>
          <Route
            exact
            path={this.props.location.pathname}
            render={routerProps => (
              <React.Fragment>
                <FormDates
                  {...routerProps}
                  onChangeDate={this.handleChangeOnDates}
                  initialDate={this.state.initialDate}
                  finalDate={this.state.finalDate}
                  oneMonth={this.state.oneMonth}
                  meters={this.state.meters}
                  onChangeOneMonth={this.handleOneMonth}
                  onMeterChange={this.handleMeterChange}
                  onQuery={this.handleQuery}
                />
                <FileInput
                  tableName={this.state.tableName}
                  dbObject={this.state.dbObject}
                />
              </React.Fragment>
            )}
          />
          <Route
            path={this.props.location.pathname + "/resultados/OM"}
            render={routerProps => (
              <ResultOM
                {...routerProps}
                energyState={this.state}
                handleNewSearch={this.showFormDates}
              />
            )}
          />
          <Route
            path={this.props.location.pathname + "/resultados/OP"}
            render={routerProps => (
              <ResultOP
                {...routerProps}
                energyState={this.state}
                handleNewSearch={this.showFormDates}
              />
            )}
          />
          <Route
            path={this.props.location.pathname + "/resultados/AM"}
            render={routerProps => (
              <ResultAM
                {...routerProps}
                energyState={this.state}
                handleNewSearch={this.showFormDates}
              />
            )}
          />
          <Route
            path={this.props.location.pathname + "/resultados/AP"}
            render={routerProps => (
              <ResultAP
                {...routerProps}
                energyState={this.state}
                handleNewSearch={this.showFormDates}
              />
            )}
          />
        </Switch>
      </React.Fragment>
    );
  }
}

export default ConsumptionMonitor;
