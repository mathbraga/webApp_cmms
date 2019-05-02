import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import EnergyResults from "./EnergyResults";
import handleDates from "../../utils/energy/handleDates";
import initializeDynamoDB from "../../utils/energy/initializeDynamoDB";
import handleSearch from "../../utils/energy/handleSearch";
import getAllMeters from "../../utils/energy/getAllMeters";
import textToArray from "../../utils/energy/textToArray";
import buildParamsArr from "../../utils/energy/buildParamsArr";
import writeItemsInDB from "../../utils/energy/writeItemsInDB";

class Energy extends Component {
  constructor(props) {
    super(props);
    this.state = {
      noEmpty: [],
      meters: [],
      dynamo: initializeDynamoDB(),
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

  handleUploadFile = event => {
    
    console.clear();
    
    // CHANGE THIS LINE. CORRECT: USE REACT-JS REFS
    let selectedFile = document.getElementById('ceb-csv-file').files[0];
    
    textToArray(selectedFile).
    then(arr => {
      console.log('arr:');
      console.log(arr);

      let paramsArr = buildParamsArr(arr, this.state.tableName);
      console.log("paramsArr:");
      console.log(paramsArr);

      writeItemsInDB(this.state.dynamo, paramsArr)
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
              />
            </>
          )}
        </div>
      </div>
    );
  }
}

export default Energy;
