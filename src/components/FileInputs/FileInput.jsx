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

class FileInput extends Component {
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
                  <Input
                    type="file"
                    id="csv-file"
                    name="csv-file"
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
                    onClick={this.props.onUploadFile}
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
