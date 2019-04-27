import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import { handleDates } from "../../utils/handleDates";
import EnergyResults from "./EnergyResults";
import { dynamoInit } from "../../utils/dynamoinit";
import handleSearch from "../../utils/handleSearch";
import getAllMeters from "../../utils/getAllMeters";
import uploadFile from "../../utils/uploadFile";

class Energy extends Component {
  constructor(props) {
    super(props);
    this.state = {
      noEmpty: [],
      meters: [],
      dynamo: dynamoInit(),
      tableName: "CEB",
      tableNameMeters: "CEB-Medidores",
      tipomed: "1",
      initialDate: "",
      finalDate: "",
      chosenMeter: "199",
      oneMonth: false,
      error: false,
      queryResponse: false,
      queryResponseAll: false,
      chartConfigs: {},
      showResult: false,
      newLocation: "",
      file: false
    };
  }

  componentDidMount() {
    getAllMeters(this.state.dynamo, this.state.tableNameMeters, this.state.tipomed).then(data => {
      this.setState({ meters: data });
    });
  }

  handleChangeOnDates = handleDates.bind(this);
  handleQuery = handleSearch.bind(this);

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
      chosenMeter: "199",
      oneMonth: prevState.oneMonth
    }));
  };

  handleFile = event => {
    event.persist();
    console.log(event.target.files);
    this.setState({file: event.target.files[0]});
  }

  handleUploadFile = event => {
    // if not logged in, or no write permission in DynamoDB:
    // alert("");

    // if logged in, manipulate the file and write items into table
    uploadFile(this.state.dynamo, this.state.tableName, this.state.file)
    .then(() => {
      console.log("Dados inseridos no banco de dados com sucesso!");
    })
    .catch(() => {
      console.log("Catch. Houve um problema.")
    });
  }

  render() {
    return (
      <div>
        <div>
          {this.state.showResult ? (
            <EnergyResults
              energyState={this.state}
              handleClick={this.showFormDates}
            />
          ) : (
            <>
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
              <FileInput
                onUploadFile={this.handleUploadFile}
                onChangeFile={this.handleFile}
              />
            </>
          )}
        </div>
      </div>
    );
  }
}

export default Energy;
