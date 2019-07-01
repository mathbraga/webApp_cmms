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
import { allAssets } from "./allAssets";

class NewWorkOrderForm extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(this.props.session),
      tableName: dbTables.workOrder.tableName,
      assetsList: [""],
      alertVisible: false,
      alertColor: "",
      alertMessage: ""
    }
  }

  handleInput = event => {
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    this.setState({
      [event.target.name]: value
    });
  }

  workOrderSubmit = event => {
    event.preventDefault();
    this.setState({
      alertVisible: true,
      alertColor: "warning",
      alertMessage: "Cadastrando ordem de serviço..."
    });
    createWorkOrder(this.state)
    .then(resolveMessage => {
      this.setState({
        alertVisible: true,
        alertColor: "success",
        alertMessage: resolveMessage
      });
    })
    .catch(rejectMessage => {
      this.setState({
        alertVisible: true,
        alertColor: "danger",
        alertMessage: rejectMessage
      });
    });
  }

  assignAsset = event => {
    let assetPosition = event.target.name;
    let assetId = event.target.value;
    this.setState(prevState => {
      let nextAssetsList = [...prevState.assetsList];
      nextAssetsList[assetPosition] = assetId;
      return {
        assetsList: nextAssetsList
      }
    });
  }

  addAsset = () => {
    if(this.state.assetsList.includes("")){
      alert('escolha um ativo antes de adicionar outro');
    } else {
      let nextAssetsList = [...this.state.assetsList];
      nextAssetsList.push("");
      this.setState({
        assetsList: nextAssetsList
      });
    }
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
                id="directions"
                name="directions"
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

            <InputGroup className="mb-3">
              <Label
              >Status:
              </Label>
              <Input
                type="text"
                id="status"
                name="status"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            {/* <InputGroup className="mb-3">
              <Label
              >Ativo:
              </Label>
              <Input
                type="text"
                id="asset"
                name="asset"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup> */}

            {this.state.assetsList.map((asset, i) => (
              <InputGroup
                className="mb-3"
                key={"asset-" + i.toString()}
              >
                <Label
                >Ativo #{(i + 1).toString()}:
                </Label>
                <Input
                  type="select"
                  id={"asset" + i.toString()}
                  name={i.toString()}
                  defaultValue=""
                  onChange={this.assignAsset}
                >
                  <option
                    key=""
                    value=""
                  >Selecione o ativo
                  </option>
                  {allAssets.map(assetId => (
                    <option
                      key={i.toString() + assetId}
                      value={assetId}
                    >{assetId}
                    </option>
                  ))}
                </Input>
              </InputGroup>
            ))}
            
            <Button
              color="warning"
              onClick={this.addAsset}
            >Adicionar ativo
            </Button>

            <InputGroup className="mb-3 ml-3">
              <Label
              >Impacto?
              </Label>
              <Input
                type="checkbox"
                id="impact"
                name="impact"
                checked={this.state.impact}
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
