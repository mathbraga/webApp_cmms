import React, { Component } from "react";
import {
  Alert,
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  Label,
  Input,
  InputGroup,
  Button,
} from "reactstrap";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { connect } from "react-redux";
import { dbTables } from "../../aws";
import createWorkOrder from "../../utils/maintenance/createWorkOrder";

class NewWorkOrderForm extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(this.props.session),
      tableName: dbTables.maintenance.tableName,
      alertVisible: false,
      alertColor: "",
      alertMessage: ""
    }
  }

  handleInput = event => {
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  workOrderSubmit = event => {
    event.preventDefault();
    this.setState({
      alertVisible: true,
      alertColor: "warning",
      alertMessage: "Enviando solicitação..."
    });
    createWorkOrder(this.state)
    .then(() => {
      this.setState({
        alertVisible: true,
        alertColor: "success",
        alertMessage: "Solicitação enviada."
      });
    })
    .catch(() => {
      this.setState({
        alertVisible: true,
        alertColor: "danger",
        alertMessage: "Houve um erro no envio da solicitação."
      });
    });
  }

  closeAlert = () => {
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
                <div className="calc-title">Nova ordem de serviço</div>
              </Col>
            </Row>
          </CardHeader>
          <CardBody>

            <InputGroup className="mb-3">
              <Label
              >Serviço selecionado:
              </Label>
              <Input
                type="text"
                id="selectedService"
                name="selectedService"
                placeholder=""
                onChange={()=>{}}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Nome (solicitante):
              </Label>
              <Input
                type="text"
                id="reqName"
                name="reqName"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >E-mail (solicitante):
              </Label>
              <Input
                type="text"
                id="reqEmail"
                name="reqEmail"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Tel (solicitante):
              </Label>
              <Input
                type="text"
                id="reqPhone"
                name="reqPhone"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Nome (contato):
              </Label>
              <Input
                type="text"
                id="conName"
                name="conName"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >E-mail (contato):
              </Label>
              <Input
                type="text"
                id="conEmail"
                name="conEmail"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Tel (contato):
              </Label>
              <Input
                type="text"
                id="conPhone"
                name="conPhone"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Endereço do local do serviço:
              </Label>
              <Input
                type="text"
                id="local"
                name="local"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Breve descrição do serviço solicitado:
              </Label>
              <Input
                type="text"
                id="description"
                name="description"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Detalhamento e justificativa para a realização do serviço:
              </Label>
              <Input
                type="text"
                id="details"
                name="details"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Anexar arquivos a esta solicitação (opcional):
              </Label>
              <Input
                type="text"
                id="files"
                name="files"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>


            <Button
              color="primary"
              onClick={this.workOrderSubmit}
              type="submit"
            >Enviar solicitação
            </Button>

          </CardBody>
        </Card>

        <Alert
          color={this.state.alertColor}
          isOpen={this.state.alertVisible}
          toggle={this.closeAlert}
        >{this.state.alertMessage}
        </Alert>

      </React.Fragment>
    );
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(NewWorkOrderForm);
