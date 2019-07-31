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
      impact: false,
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
    let i = parseInt(event.target.name, 10);
    let assetId = event.target.value;
    if(this.state.assetsList.includes(assetId)){
      alert('ATIVO REPETIDO! O ATIVO SERÁ REMOVIDO DA LISTA.');
      this.setState(prevState => {
        let nextAssetsList = [...prevState.assetsList];
        nextAssetsList.splice(i, 1);
        return {
          assetsList: nextAssetsList
        }
      });
    } else {
      this.setState(prevState => {
        let nextAssetsList = [...prevState.assetsList];
        nextAssetsList[i] = assetId;
        return {
          assetsList: nextAssetsList
        }
      });
    }
  }

  addAsset = () => {
    let nextAssetsList = [...this.state.assetsList];
    nextAssetsList.push("");
    this.setState({
      assetsList: nextAssetsList
    });
  }

  removeAsset = event => {
    let i = parseInt(event.target.name, 10);
    if(this.state.assetsList.length === 1){
      alert("Pelo menos um ativo deve ser escolhido.");
    } else {
      let nextAssetsList = [...this.state.assetsList];
      nextAssetsList.splice(i, 1);
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

            {this.state.assetsList.map((asset, i) => (
              <InputGroup
                className="mb-3"
                key={"asset-" + i.toString()}
              >
                <Label>{"Ativo #" + (i + 1).toString() + ": "}</Label>
                <Input
                  type="select"
                  id={"asset-" + i.toString()}
                  name={i.toString()}
                  defaultValue=""
                  onChange={this.assignAsset}
                >
                  <option
                    value=""
                  >Selecione o ativo
                  </option>
                  {allAssets.map(asset => (
                    <option
                      key={"asset-" + i.toString() + "-" + asset.id}
                      value={asset.id}
                    >{asset.id}
                    </option>
                  ))}
                </Input>

                <Button
                  color="secondary"
                  name={i.toString()}
                  onClick={this.removeAsset}
                >Remover</Button>
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
