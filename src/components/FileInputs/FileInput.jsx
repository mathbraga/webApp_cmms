import React, { Component } from "react";
import {
  Alert,
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  CustomInput,
  FormGroup,
  Button,
} from "reactstrap";
import textToArray from "../../utils/consumptionMonitor/textToArray";
import buildCEBParamsArr from "../../utils/consumptionMonitor/buildCEBParamsArr";
import writeItemsInDB from "../../utils/consumptionMonitor/writeItemsInDB";
// import buildCAESBParamsArr from "../../utils/consumptionMonitor/buildCAESBParamsArr";

class FileInput extends Component {
  constructor(props){
    super(props);
    this.fileInputRef = React.createRef();
    this.state = {
      selected: false,
      alertVisible: false,
      alertColor: "",
      alertMessage: ""
    };
  }

  handleSelection = event => {
    if(this.fileInputRef.current.files.length > 0){
      this.setState({
        selected: true
      });
    } else {
      this.setState({
        selected: false
      });
    }
  }

  handleUploadFile = event => {
    
    event.preventDefault();

    this.setState({
      alertVisible: true,
      alertColor: "warning",
      alertMessage: "Realizando o upload. Aguarde..."
    });

    let selectedFile = this.fileInputRef.current.files[0];

    textToArray(selectedFile).
    then(arr => {
      // console.log('arr:');
      // console.log(arr);

      let paramsArr = buildCEBParamsArr(arr, this.props.tableName);
      
      // console.log("paramsArr:");
      // console.log(paramsArr);

      writeItemsInDB(this.props.dbObject, paramsArr)
      .then(() => {
        this.setState({
          alertVisible: true,
          alertMessage: "Upload realizado com sucesso!",
          alertColor: "success",
        });
      })
      .catch(() => {
        this.setState({
          alertVisible: true,
          alertMessage: "Houve um problema no upload do arquivo.",
          alertColor: "danger"
        });
      });
    })
    .catch(() => {
      this.setState({
        alertVisible: true,
        alertMessage: "Houve um problema na leitura do arquivo.",
        alertColor: "danger"
      });
    });
  }

  closeAlert = event => {
    this.setState({
      alertVisible: false
    });
  }
  
  render() {
    return (
      <React.Fragment>
        <Card>
          <CardHeader>
            <Row>
              <Col md="12">
                <div className="calc-title">Upload de arquivo</div>
                <div className="calc-subtitle">
                  <em>Utilizar faturas em formato csv</em>
                </div>
              </Col>
            </Row>
          </CardHeader>
          <CardBody>
            <Row>

              <Col xs="3">
                <FormGroup>
                  <CustomInput
                    label="Clique ou arraste para selecionar"
                    type="file"
                    id="csv-file"
                    name="csv-file"
                    innerRef={this.fileInputRef}
                    onChange={this.handleSelection}
                  />
                </FormGroup>
              </Col>
              <Col xs="3">
                {this.state.selected
                  ? <p>Arquivo selecionado:
                      <strong>
                        {" " + this.fileInputRef.current.files[0].name}
                      </strong>
                    </p>
                  : <p>Nenhum arquivo selecionado</p>
                }
              </Col>
              <Col xs="3">
                <Button
                  className=""
                  type="submit"
                  size="md"
                  color={(this.state.alertColor === "warning" || !this.state.selected) ? "secondary" : "primary"}
                  disabled={(this.state.alertColor === "warning" || !this.state.selected) ? true : false}
                  style={{ margin: "10px 20px" }}
                  onClick={this.handleUploadFile}
                >Enviar arquivo
                </Button>
              </Col>
            </Row>
          </CardBody>
        </Card>

        <Alert
          className="mt-4"
          color={this.state.alertColor}
          isOpen={this.state.alertVisible}
          toggle={this.closeAlert}
        >{this.state.alertMessage}
        </Alert>

      </React.Fragment>
    );
  }
}

export default FileInput;
