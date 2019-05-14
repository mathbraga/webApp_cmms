import React, { Component } from "react";
import {
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  CustomInput,
  FormGroup,
  Button,
} from "reactstrap";
import textToArray from "../../utils/energy/textToArray";
import buildCEBParamsArr from "../../utils/energy/buildCEBParamsArr";
import writeItemsInDB from "../../utils/energy/writeItemsInDB";
import buildCAESBParamsArr from "../../utils/water/buildCAESBParamsArr";

class FileInput extends Component {
  constructor(props){
    super(props);
    this.fileInputRef = React.createRef();
    this.state = {
      selectedState: false
    };
  }

  handleSelection = event => {
    if(this.fileInputRef.current.files.length > 0){
      this.setState({
        selectedState: true
      });
    } else {
      this.setState({
        selectedState: false
      });
    }
  }

  handleUploadFile = event => {
    
    event.preventDefault();

    console.clear();
    
    let selectedFile = this.fileInputRef.current.files[0];
    
    console.log('selectedFile:');
    console.log(selectedFile);

    textToArray(selectedFile).
    then(arr => {
      console.log('arr:');
      console.log(arr);

      let paramsArr = [];
      
      if(this.props.tableName === "CEBteste"){
        paramsArr = buildCEBParamsArr(arr, this.props.tableName);
      } else {
        paramsArr = buildCAESBParamsArr(arr, this.props.tableName);
      }
      
      console.log("paramsArr:");
      console.log(paramsArr);

      writeItemsInDB(this.props.dbObject, paramsArr)
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

            {!this.state.selectedState
              ? (
                <React.Fragment>
                  <Col xs="3">
                    <p>Nenhum arquivo selecionado</p>
                  </Col>
                  <Col xs="3">
                  <Button
                    className=""
                    type="submit"
                    size="md"
                    color="secondary"
                    disabled
                    style={{ margin: "10px 20px" }}
                  >Enviar arquivo
                  </Button>
                  </Col>
                </React.Fragment>
              ) : (
                <React.Fragment>
                  <Col xs="3">
                    <p>Arquivo selecionado:{" " + this.fileInputRef.current.files[0].name}</p>
                  </Col>
                  <Col xs="3">
                  <Button
                    className=""
                    type="submit"
                    size="md"
                    color="primary"
                    onClick={this.handleUploadFile}
                    style={{ margin: "10px 20px" }}
                  >Enviar arquivo
                  </Button>
                  </Col>
                </React.Fragment>
              )
            }
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default FileInput;
