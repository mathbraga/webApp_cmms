import React, { Component } from "react";
import {
  Row,
  Col,
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Form,
  FormGroup,
  Label,
  Input,
  CustomInput
} from "reactstrap";
import SingleInputWithDropdown from "../Forms/SingleInputWithDropdown";

import "./ModalCreateFilter.css";

const filterOperations = {
  option: {
    equalTo: { description: 'igual a', optionsType: 'selectMany' },
    different: { description: 'diferente de', optionsType: 'selectMany' },
    notNull: { description: 'não nulo', optionsType: 'nothing' },
    null: { description: 'nulo', optionsType: 'nothing' }
  },
  text: {
    include: { description: 'contém', optionsType: 'text' },
    notInclude: { description: 'não contém', optionsType: 'text' },
    notNull: { description: 'não nulo', optionsType: 'nothing' },
    null: { description: 'nulo', optionsType: 'nothing' }
  },
  number: {
    equalTo: { description: 'igual a', optionsType: 'number' },
    greaterThan: { description: 'maior que', optionsType: 'number' },
    lowerThan: { description: 'menor que', optionsType: 'number' },
    different: { description: 'diferente de', optionsType: 'number' },
    between: { description: 'entre', optionsType: 'twoNumbers' },
  },
};

const inputBasedOnOperator = {
  selectMany: (
    <Input
      type="select"
      name="attribute"
      id="attribute"
      multiple
    >
      <option>A</option>
      <option>B</option>
      <option>C</option>
      <option>D</option>
    </Input>
  ),
  selectOne: (
    <Input
      type="select"
      name="attribute"
      id="attribute"
      multiple
    >
      <option>A</option>
      <option>B</option>
      <option>C</option>
      <option>D</option>
    </Input>
  ),
  nothing: null,
  text: (
    <Input
      type="text"
      name="attribute"
      id="attribute"
    />
  ),
  number: (
    <Input
      type="text"
      name="attribute"
      id="attribute"
    />
  ),
  twoNumbers: null,
};

class ModalCreateFilter extends Component {
  constructor(props) {
    super(props);
    this.state = {
      filterName: '',
      attribute: null,
      operator: null,
      option: null,
      inputBasedOnOperator: 'nothing',
    };

    this.handleInputSelectClick = this.handleInputSelectClick.bind(this);
  }

  updateValue = (param) => (itemId) => {
    this.setState(
      { [param]: itemId }
    );
  }

  handleInputSelectClick(event) {
    console.log("Handle:")
    console.log(event.target.value[0]);
    console.log(event.target.value[1]);
    this.setState({
      operator: event.target.value[0],
      inputBasedOnOperator: event.target.value[1],
    });
  }

  render() {
    const {
      toggle,
      modal,
      attributes
    } = this.props;

    const type = this.state.attribute && attributes[this.state.attribute].type;

    console.log('State: ', this.state);

    const listDropdown = Object.keys(attributes).map(key => (
      { id: key, text: attributes[key].name, subtext: '' }
    ))

    return (
      <Modal
        isOpen={modal}
        toggle={toggle}
        size={'lg'}
        backdrop={'static'}
      >
        <div className='filter-header'>
          <Row>
            <Col md="8" xs="6">
              <div className="widget-title dash-title text-truncate">
                <h4>Cadastrar Filtro</h4>
                <div className="dash-subtitle text-truncate">
                  Formulário para criação de filtros
                </div>
              </div>
            </Col>
            <Col md="4" xs="6" className="container-left">
              <Button
                onClick={() => { }}
                className="ghost-button" style={{ width: "auto", height: "38px", padding: "8px 40px" }}>Filtros Prontos</Button>
            </Col>
          </Row>
        </div>
        <ModalBody>
          <FormGroup row>
            <Label for="filterName" sm={2}>Nome</Label>
            <Col sm={10}>
              <Input type="text" name="filterName" id="filterName" />
            </Col>
          </FormGroup>
          <div className="switch-container">
            <Row>
              <Col sm={2} />
              <Col sm={10}>
                <CustomInput type="switch" id="saveSwitch" name="saveSwitch" label="Aplicar filtro sem salvar" />
              </Col>
            </Row>
          </div>
          <div className='create-filter-container'>
            <div className={'filter-container-title'}>
              <div className="filter-title">
                Monte seu Filtro
              </div>
            </div>
            <div className="filter-container-body">
              <FormGroup row>
                <Label for="attribute" sm={3}>Atributo / Operação</Label>
                <Col sm={9}>
                  <SingleInputWithDropdown
                    withLabel={false}
                    listDropdown={listDropdown}
                    required
                    update={this.updateValue('attribute')}
                    value={this.state.attribute && attributes[this.state.attribute].name}
                  />
                </Col>
              </FormGroup>
              <FormGroup row style={{ minHeight: "93px" }}>
                <Col sm={4} style={{ margin: "auto 0" }}>
                  <Input
                    style={{ textAlign: "center" }}
                    value={this.state.attribute && attributes[this.state.attribute].name}
                    disabled
                    type="text"
                    name="attribute"
                    id="attribute"
                  />
                </Col>
                <Col sm={4} style={{ margin: "auto 0" }}>
                  <Input
                    className={!this.state.attribute ? 'remove-input' : ''}
                    type="select"
                    name="attribute"
                    id="attribute"
                    onClick={this.handleInputSelectClick}
                  >
                    {this.state.attribute && Object.keys(filterOperations[type]).map(option => (
                      <option value={option} >{filterOperations[type][option].description}</option>
                    ))}
                  </Input>
                </Col>
                <Col sm={4}>
                  <Input
                    className={!this.state.attribute ? 'remove-input' : ''}
                    type="select"
                    name="attribute"
                    id="attribute"
                    multiple
                  >
                    <option>A</option>
                    <option>B</option>
                    <option>C</option>
                    <option>D</option>
                  </Input>
                </Col>
              </FormGroup>
              <Button color="primary">Adicionar</Button>
              <Button color="danger" style={{ marginLeft: "10px" }}>Limpar</Button>
            </div>
          </div>
          <div className='create-filter-container'>
            <div className={'filter-container-title'}>
              <div className="filter-title">
                Resultado
              </div>
            </div>
          </div>
        </ModalBody>
        <ModalFooter className={'filter-footer'}>
          <Button color="success">Criar Filtro</Button>
          <Button color="danger" onClick={toggle}>Cancelar</Button>
        </ModalFooter>
      </Modal>
    );
  }
}

export default ModalCreateFilter;