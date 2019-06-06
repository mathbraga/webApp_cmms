import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import handleDates from "../../utils/consumptionMonitor/handleDates";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { query, queryReset } from "../../redux/actions";
import getAllMeters from "../../utils/consumptionMonitor/getAllMeters";
import getCurrentMonth from "../../utils/consumptionMonitor/getCurrentMonth";
import { Route, Switch } from "react-router-dom";
import ResultOM from "./ResultOM";
import ResultOP from "./ResultOP";
import ResultAM from "./ResultAM";
import ResultAP from "./ResultAP";
import { connect } from "react-redux";
import { Alert } from "reactstrap";
import { dbTables } from "../../aws";

class ConsumptionMonitor extends Component {
  constructor(props) {
    super(props);
    this.awsData = {
      tableName: dbTables[this.props.monitor].tableName,
      tableNameMeters: dbTables[this.props.monitor].tableNameMeters,
      meterType: dbTables[this.props.monitor].meterType,
      defaultMeter: dbTables[this.props.monitor].meterType + "99",
      dbObject: initializeDynamoDB(this.props.session)
    }
    this.state = {
      meters: [],
      initialDate: getCurrentMonth(),
      finalDate: "",
      chosenMeter: this.awsData.defaultMeter,
      oneMonth: true,
      alertMessage: false,
      alertVisible: false
    };
  }

  componentDidMount() {
    getAllMeters(this.awsData).then(meters => {
      this.setState({
        meters: meters
      });
    });
  }

  componentDidUpdate = prevProps => {
    if(this.props.queryError !== prevProps.queryError){
      if(this.props.queryError || this.props.isFetching){
        this.setState({
          alertVisible: true,
          alertMessage: this.props.message
        });
      }
    }
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
    this.props.query(this.awsData, this.state);
  }

  showFormDates = () => {
    this.props.queryReset();
    this.setState(prevState => ({
      initialDate: prevState.initialDate,
      finalDate: prevState.finalDate,
      chosenMeter: prevState.chosenMeter,
      oneMonth: prevState.oneMonth,
    }));
  };

  closeAlert = event => {
    this.setState({
      alertVisible: false
    });
  }

  render() {
    return (
      <React.Fragment>
        {!this.props.showResult &&
          <React.Fragment>
            <FormDates
              onChangeDate={this.handleChangeOnDates}
              initialDate={this.state.initialDate}
              chosenMeter={this.state.chosenMeter}
              finalDate={this.state.finalDate}
              oneMonth={this.state.oneMonth}
              meters={this.state.meters}
              onChangeOneMonth={this.handleOneMonth}
              onMeterChange={this.handleMeterChange}
              onQuery={this.handleQuery}
            />

            <Alert className="mt-4" color="danger" isOpen={this.state.alertVisible} toggle={this.closeAlert}>
              {this.state.alertMessage}
            </Alert>

            {this.props.session &&
              <FileInput
                tableName={this.awsData.tableName}
                dbObject={this.awsData.dbObject}
              />
            }
          </React.Fragment>
        }
        {this.props.showResult &&
          <Switch location={this.props.resultObject.newLocation}>
            <Route
              path={this.props.location.pathname + "/resultados/OM"}
              render={routerProps => (
                <ResultOM
                  {...routerProps}
                  consumptionState={this.state}
                  awsData={this.awsData}
                  resultObject={this.props.resultObject}
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
                  awsData={this.awsData}
                  resultObject={this.props.resultObject}
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
                  awsData={this.awsData}
                  resultObject={this.props.resultObject}
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
                  awsData={this.awsData}
                  resultObject={this.props.resultObject}
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
    resultObject: storeState.energy.resultObject,
    queryError: storeState.energy.queryError,
    message: storeState.energy.message,
    isFetching: storeState.energy.isFetching,
    showResult: storeState.energy.showResult
  }
}

const mapDispatchToProps = dispatch => {
  return {
    query: (awsData, state) => dispatch(query(awsData, state)),
    queryReset: () => dispatch(queryReset())
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ConsumptionMonitor);
