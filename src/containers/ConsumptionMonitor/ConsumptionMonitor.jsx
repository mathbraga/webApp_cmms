import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import handleDates from "../../utils/consumptionMonitor/handleDates";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import handleSearch from "../../utils/consumptionMonitor/handleSearch";
import getAllMeters from "../../utils/consumptionMonitor/getAllMeters";
import getCurrentMonth from "../../utils/consumptionMonitor/getCurrentMonth";
import { Route, Switch } from "react-router-dom";
import ResultOM from "./ResultOM";
import ResultOP from "./ResultOP";
import ResultAM from "./ResultAM";
import ResultAP from "./ResultAP";
import { connect } from "react-redux";

class ConsumptionMonitor extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tableName: this.props.tableName,             // This prop comes from route.options
      tableNameMeters: this.props.tableNameMeters, // This prop comes from route.options
      meterType: this.props.meterType,             // This prop comes from route.options
      defaultMeter: this.props.meterType + "99",   // This prop comes from route.options
      meters: [],
      dbObject: this.props.dbObject,               // This prop comes from mapStateToProps()
      initialDate: getCurrentMonth(),
      finalDate: "",
      chosenMeter: this.props.meterType + "99",    // This prop comes from route.options
      oneMonth: true,
      showResult: false,
      resultObject: {}
    };
  }

  componentDidMount() {
    getAllMeters(this.state).then(meters => {
      this.setState({
        meters: meters
      });
    });
  }

  handleChangeOnDates = handleDates.bind(this);
  
  handleQuery = event => {
    handleSearch(this.state).then(resultObject => {
      this.setState({
        showResult: true,
        resultObject: resultObject
      });
    }).catch((errorMessage) => {
      alert(errorMessage);
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
      initialDate: prevState.initialDate,
      finalDate: prevState.finalDate,
      chosenMeter: prevState.defaultMeter,
      oneMonth: prevState.oneMonth,
      showResult: false
    }));
  };

  render() {
    return (
      <React.Fragment>
        {!this.state.showResult &&
          <React.Fragment>
            <FormDates
              onChangeDate={this.handleChangeOnDates}
              initialDate={this.state.initialDate}
              finalDate={this.state.finalDate}
              oneMonth={this.state.oneMonth}
              meters={this.state.meters}
              onChangeOneMonth={this.handleOneMonth}
              onMeterChange={this.handleMeterChange}
              onQuery={this.handleQuery}
            />
            {this.props.enableFileInput &&
              <FileInput
                tableName={this.state.tableName}
                dbObject={this.state.dbObject}
              />
            }
          </React.Fragment>
        }
        {this.state.showResult &&
          <Switch location={this.state.resultObject.newLocation}>
            <Route
              path={this.props.location.pathname + "/resultados/OM"}
              render={routerProps => (
                <ResultOM
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />
            <Route
              path={this.props.location.pathname + "/resultados/OP"}
              render={routerProps => (
                <ResultOP
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />
            <Route
              path={this.props.location.pathname + "/resultados/AM"}
              render={routerProps => (
                <ResultAM
                  {...routerProps}
                  consumptionState={this.state}
                  handleNewSearch={this.showFormDates}
                />
              )}
            />
            <Route
              path={this.props.location.pathname + "/resultados/AP"}
              render={routerProps => (
                <ResultAP
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

const mapStateToProps = (storeState, ownProps) => {
  console.log('store state:');
  console.log(storeState);
  console.log('own props:');
  console.log(ownProps);
  let enableFileInput = false;
  if(storeState.userSession){
    enableFileInput = true;
  }
  return {
    dbObject: initializeDynamoDB(storeState.userSession),
    enableFileInput: enableFileInput
  }
}

export default connect(mapStateToProps)(ConsumptionMonitor);
