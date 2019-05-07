import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import WaterResults from "./WaterResults";
import handleDates from "../../utils/energy/handleDates";
import initializeDynamoDB from "../../utils/energy/initializeDynamoDB";
import handleSearch from "../../utils/energy/handleSearch";
import getAllMeters from "../../utils/energy/getAllMeters";
import textToArray from "../../utils/energy/textToArray";
import buildCAESBParamsArr from "../../utils/water/buildCAESBParamsArr";
import writeItemsInDB from "../../utils/energy/writeItemsInDB";

class Water extends Component {
  constructor(props) {
    super(props);
    this.tableName = "CAESBteste";
    this.tableNameMeters = "CAESB-Medidores";
    this.meterType = "2";
    this.defaultMeter = this.meterType + "99";
    this.state = {
      nonEmptyMeters: [],
      meters: [],
      dbObject: initializeDynamoDB(),
      initialDate: "",
      finalDate: "",
      chosenMeter: "299",
      oneMonth: false,
      error: false,
      queryResponse: false,
      queryResponseAll: false,
      chartConfigs: {},
      showResult: false,
      newLocation: "",
    };
  }

  componentDidMount() {
    getAllMeters(this.state.dbObject, this.tableNameMeters, this.meterType).then(meters => {
      this.setState({
        meters: meters
      });
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
      chosenMeter: "299",
      oneMonth: prevState.oneMonth
    }));
  };

  handleUploadFile = event => {
    
    console.clear();
    
    // CHANGE THIS LINE. CORRECT: USE REACT-JS REFS
    let selectedFile = document.getElementById('csv-file').files[0];
    
    textToArray(selectedFile).
    then(arr => {
      console.log('arr:');
      console.log(arr);

      let paramsArr = buildCAESBParamsArr(arr, this.tableName);
      console.log("paramsArr:");
      console.log(paramsArr);

      writeItemsInDB(this.state.dbObject, paramsArr)
      .then(() => {
        console.log("Upload de dados realizado com sucesso!");
      })
      .catch(() => {
        console.log("Houve um problema no upload do arquivo.");
      });
    })
    .catch(() => {
      console.log("Houve um problema na leitura do arquivo.");
    });
  }

  render() {
    return (
      <>
        {this.state.showResult ? (
          <WaterResults
            waterState={this.state}
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
            />
          </>
        )}
      </>
    );
  }
}

export default Water;