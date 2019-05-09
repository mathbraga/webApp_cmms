import React, { Component } from "react";
import {
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  Input,
  FormGroup,
  Button,
} from "reactstrap";
import textToArray from "../../utils/energy/textToArray";
import buildCEBParamsArr from "../../utils/energy/buildCEBParamsArr";
import writeItemsInDB from "../../utils/energy/writeItemsInDB";

class FileInput extends Component {
  constructor(props){
    super(props);
    this.fileInputRef = React.createRef();
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

      let paramsArr = buildCEBParamsArr(arr, this.props.tableName);
      console.log("paramsArr:");
      console.log(paramsArr);

    //   writeItemsInDB(this.props.dbObject, paramsArr)
    //   .then(() => {
    //     console.log("Upload de dados realizado com sucesso!");
    //   })
    //   .catch(() => {
    //     console.log("Houve um problema no upload do arquivo.");
    //   });
    // })
    // .catch(() => {
    //   console.log("Houve um problema na leitura do arquivo.");
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
                <Col>
                  <input
                    type="file"
                    id="csv-file"
                    name="csv-file"
                    ref={this.fileInputRef}
                  />
                </Col>
              </FormGroup>
            </Col>

            <Col xs="3">
              <FormGroup>
                <Col>
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
              </FormGroup>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default FileInput;
