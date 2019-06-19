import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import handleDates from "../../utils/consumptionMonitor/handleDates";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { saveSearchResult } from "../../redux/actions";
import handleSearch from "../../utils/consumptionMonitor/handleSearch";
import getAllMeters from "../../utils/consumptionMonitor/getAllMeters";
import getCurrentMonth from "../../utils/consumptionMonitor/getCurrentMonth";
import { Route, Switch } from "react-router-dom";
import ResultOM from "./ResultOM";
import ResultOP from "./ResultOP";
import ResultAM from "./ResultAM";
import ResultAP from "./ResultAP";
// import ResultOMwater from "./ResultOMwater";
// import ResultOPwater from "./ResultOPwater";
import ResultAMwater from "./ResultAMwater";
import ResultAPwater from "./ResultAPwater";
import { connect } from "react-redux";
import { Alert } from "reactstrap";
import { dbTables } from "../../aws";

class ConsumptionMonitor extends Component {
  constructor(props) {
    super(props);

    this.monitor = this.props.location.pathname === "/energia" ? "energy" : "water";

    if(this.props.consumptionMonitorCache[this.monitor]){
      this.state = this.props.consumptionMonitorCache[this.monitor];
    } else {
      this.state = {
        tableName: dbTables[this.monitor].tableName,
        tableNameMeters: dbTables[this.monitor].tableNameMeters,
        meterType: dbTables[this.monitor].meterType,
        defaultMeter: dbTables[this.monitor].meterType + "99",
        dbObject: initializeDynamoDB(this.props.session),
        meters: [],
        initialDate: getCurrentMonth(),
        finalDate: "",
        chosenMeter: dbTables[this.monitor].meterType + "99",
        oneMonth: true,
        alertVisible: false,
        alertMessage: "",
        searchError: false,
        resultObject: {},
        showResult: false
      };
    }
  }

  componentDidMount = () => {
    getAllMeters(this.state.dbObject, this.state.tableNameMeters, this.state.meterType).then(meters => {
      this.setState({
        meters: meters
      });
    });
  }

  handleChangeOnDates = handleDates.bind(this);

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

  handleQuery = event => {
    
    event.preventDefault();

    this.setState({
      alertVisible: true,
      alertMessage: "Consultando banco de dados...",
      searchError: false,
    });

    handleSearch(this.state)
    .then(resultObject => {
      this.setState({
        resultObject: resultObject,
        showResult: true,
        searchError: false
      });
    })
    .catch(alertMessage => {
      this.setState({
        alertMessage: alertMessage,
        alertVisible: true,
        searchError: true
      });
    });

  }

  showFormDates = () => {
    // this.props.queryReset();
    this.setState(prevState => ({
      initialDate: prevState.initialDate,
      finalDate: prevState.finalDate,
      chosenMeter: prevState.chosenMeter,
      oneMonth: prevState.oneMonth,
      alertVisible: false,
      showResult: false
    }));
  };

  closeAlert = () => {
    this.setState({
      alertVisible: false
    });
  }

  componentWillUnmount = () => {
    this.props.dispatch(saveSearchResult(this.state, this.monitor));
  }

  render() {
    return (
      <React.Fragment>
        {!this.state.showResult &&
          <React.Fragment>
            <FormDates
              consumptionState={this.state}
              onChangeDate={this.handleChangeOnDates}
              onChangeOneMonth={this.handleOneMonth}
              onMeterChange={this.handleMeterChange}
              onQuery={this.handleQuery}
            />

            <Alert
              className="mt-4"
              color={this.state.searchError ? "danger" : "warning"}
              isOpen={this.state.alertVisible}
              toggle={this.closeAlert}
            >{this.state.alertMessage}
            </Alert>

            <FileInput
              tableName={this.state.tableName}
              dbObject={this.state.dbObject}
              readFile={dbTables[this.monitor].readFile}
              buildParamsArr={dbTables[this.monitor].buildParamsArr}
            />

          </React.Fragment>
        }
        {this.state.showResult &&
          <Switch location={this.state.resultObject.newLocation}>
            <Route
              path={"/energia/resultados/OM"}
              render={routerProps => (
                <ResultOM
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />
            <Route
              path={"/energia/resultados/OP"}
              render={routerProps => (
                <ResultOP
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />
            <Route
              path={"/energia/resultados/AM"}
              render={routerProps => (
                <ResultAM
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />
            <Route
              path={"/energia/resultados/AP"}
              render={routerProps => (
                <ResultAP
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />



            {/* <Route
              path={"/agua/resultados/OM"}
              render={routerProps => (
                <ResultOM
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            /> */}
            {/* <Route
              path={"/agua/resultados/OP"}
              render={routerProps => (
                <ResultOP
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            /> */}
            <Route
              path={"/agua/resultados/AM"}
              render={routerProps => (
                <ResultAMwater
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />
            <Route
              path={"/agua/resultados/AP"}
              render={routerProps => (
                <ResultAPwater
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />


          </Switch>
        }
      </React.Fragment>
    );
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session,
    consumptionMonitorCache: storeState.consumptionMonitorCache
    // resultObject: storeState.energy.resultObject,
    // queryError: storeState.energy.queryError,
    // message: storeState.energy.message,
    // isFetching: storeState.energy.isFetching,
    // showResult: storeState.energy.showResult
  }
}

// const mapDispatchToProps = dispatch => {
//   return {
//     query: (awsData, state) => dispatch(query(awsData, state)),
//     queryReset: () => dispatch(queryReset())
//   }
// }

export default connect(
  mapStateToProps
)(ConsumptionMonitor);