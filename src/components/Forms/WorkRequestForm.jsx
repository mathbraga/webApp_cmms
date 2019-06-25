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
import createWorkRequest from "../../utils/work/createWorkRequest";
import Calendar from "react-calendar";
/* Custom styling
If you don't want to use default React-Calendar styling to build upon it,
you can import React-Calendar by using
import Calendar from 'react-calendar/dist/entry.nostyle';
instead.
*/

class WorkRequestForm extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(this.props.session),
      tableName: dbTables.work.tableName,
      description: "",
      facilities: "",
      impactType: "",
      initialDate: new Date(),
      finalDate: new Date(),
      alertVisible: false,
      alertMessage: ""
    }
  }

  handleInput = event => {
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  onChangePeriod = dateArr => {
    this.setState({
      initialDate: dateArr[0],
      finalDate: dateArr[1]
    });
  }

  workRequestSubmit = event => {
    event.preventDefault();
    this.setState({
      alertVisible: true,
      alertColor: "warning",
      alertMessage: "Adicionando ação impactante..."
    });
    createWorkRequest(this.state)
    .then(() => {
      this.setState({
        alertVisible: true,
        alertColor: "success",
        alertMessage: "Tudo certo."
      });
    })
    .catch(() => {
      this.setState({
        alertVisible: true,
        alertColor: "danger",
        alertMessage: "Houve um erro."
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
                <div className="calc-title">Solicitação de serviço</div>
              </Col>
            </Row>
          </CardHeader>
          <CardBody>

            <InputGroup className="mb-3">
              <Label
              >Breve descrição do serviço solicitado:
              </Label>
              <Input
                autoFocus
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
              />
            </InputGroup>



            <InputGroup className="mb-3">
              <Label
              >Local impactado:
              </Label>
              <Input
                type="text"
                id="facilities"
                name="facilities"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >Tipo do impacto:
              </Label>
              <Input
                type="select"
                id="impactType"
                name="impactType"
                defaultValue="Cheiro forte"
                onChange={this.handleInput}
              >
                <option
                  value="Cheiro forte"
                >Cheiro forte
                </option>
                <option
                  value="Poeira"
                >
                  Poeira
                </option>
                <option
                  value="Barulho"
                >Barulho
                </option>
              </Input>
            </InputGroup>

            <Label
              >{"Período: " + this.state.initialDate.getDate() + "/" + (this.state.initialDate.getMonth() + 1) + "/" + this.state.initialDate.getFullYear()}
              {" a " + this.state.finalDate.getDate() + "/" + (this.state.finalDate.getMonth() + 1) + "/" + this.state.finalDate.getFullYear()}
            </Label>
            <Calendar
              className="mb-3"
              calendarType="US"
              onChange={this.onChangePeriod}
              showFixedNumberOfWeeks={true}
              returnValue="range"
              selectRange={true}
            />

            <Button
              color="primary"
              onClick={this.workRequestSubmit}
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

export default connect(mapStateToProps)(WorkRequestForm);
