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
import { connect } from "react-redux";
import createWorkOrder from "../../utils/maintenance/createWorkOrder";
import { allAssets } from "./allAssets";

class NewWorkOrderForm extends Component {
  constructor(props){
    super(props);
    this.state = {
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
              >status1
              </Label>
              <Input
                type="text"
                id="status1"
                name="status1"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >prioridade
              </Label>
              <Input
                type="text"
                id="prioridade"
                name="prioridade"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >origem
              </Label>
              <Input
                type="text"
                id="origem"
                name="origem"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>

            <InputGroup className="mb-3">
              <Label
              >responsavel
              </Label>
              <Input
                type="text"
                id="responsavel"
                name="responsavel"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >categoria
              </Label>
              <Input
                type="text"
                id="categoria"
                name="categoria"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >servico
              </Label>
              <Input
                type="text"
                id="servico"
                name="servico"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >descricao
              </Label>
              <Input
                type="text"
                id="descricao"
                name="descricao"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >data_inicial
              </Label>
              <Input
                type="text"
                id="data_inicial"
                name="data_inicial"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >data_prazo
              </Label>
              <Input
                type="text"
                id="data_prazo"
                name="data_prazo"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >realizado
              </Label>
              <Input
                type="text"
                id="realizado"
                name="realizado"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >data_criacao
              </Label>
              <Input
                type="text"
                id="data_criacao"
                name="data_criacao"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >data_atualiz
              </Label>
              <Input
                type="text"
                id="data_atualiz"
                name="data_atualiz"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >sigad
              </Label>
              <Input
                type="text"
                id="sigad"
                name="sigad"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >solic_orgao
              </Label>
              <Input
                type="text"
                id="solic_orgao"
                name="solic_orgao"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >solic_nome
              </Label>
              <Input
                type="text"
                id="solic_nome"
                name="solic_nome"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >contato_nome
              </Label>
              <Input
                type="text"
                id="contato_nome"
                name="contato_nome"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >contato_email
              </Label>
              <Input
                type="text"
                id="contato_email"
                name="contato_email"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >contato_tel
              </Label>
              <Input
                type="text"
                id="contato_tel"
                name="contato_tel"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >mensagem
              </Label>
              <Input
                type="text"
                id="mensagem"
                name="mensagem"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >orcamento
              </Label>
              <Input
                type="text"
                id="orcamento"
                name="orcamento"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >conferido
              </Label>
              <Input
                type="text"
                id="conferido"
                name="conferido"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >lugar
              </Label>
              <Input
                type="text"
                id="lugar"
                name="lugar"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >executante
              </Label>
              <Input
                type="text"
                id="executante"
                name="executante"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >os_num
              </Label>
              <Input
                type="text"
                id="os_num"
                name="os_num"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >ans
              </Label>
              <Input
                type="text"
                id="ans"
                name="ans"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >status2
              </Label>
              <Input
                type="text"
                id="status2"
                name="status2"
                placeholder=""
                onChange={this.handleInput}
              />
            </InputGroup>
            <InputGroup className="mb-3">
              <Label
              >multitarefa
              </Label>
              <Input
                type="text"
                id="multitarefa"
                name="multitarefa"
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

            {/* <InputGroup className="mb-3 ml-3">
              <Label
              >Impacto?
              </Label>
              <Input
                type="checkbox"
                id="impact"
                name="impact"
                onChange={this.handleInput}
              />
            </InputGroup> */}

            <InputGroup>
              <Button
                color="primary"
                onClick={this.workOrderSubmit}
                type="submit"
              >Enviar solicitação
              </Button>
            </InputGroup>

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
