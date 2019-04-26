import React, { Component } from "react";
import {
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  Label,
  Input,
  FormGroup,
  Button,
  CustomInput
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
                <em>Utilizar faturas em formato csv encaminhadas pela CEB</em>
              </div>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Row>

            <Col xs="3">
              <FormGroup>
                <Col>
                  {/* <Label htmlFor="ceb-csv-file"></Label> */}
                  <Input type="file" id="ceb-csv-file" name="ceb-csv-file"/>
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
                    onClick={this.props.onQuery}
                    style={{ margin: "10px 20px" }}
                  >
                    Enviar arquivo
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
