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

const filterResultUI = (filterLogic, attributes, operators) => {
  const resultUI = [];
  const termUIOperators = {
    selectMany: 'ou',
    text: 'e',
    twoNumbers: 'e',
  };
  filterLogic.forEach(logic => {
    const { type, attribute, verb, term } = logic;
    if (type === 'att') {
      const attUI = attributes[attribute].name;
      const attType = attributes[attribute].type;
      const verbUI = operators[attType][verb].description;
      const termOptionsType = operators[attType][verb].optionsType;
      const termUIOperator = termUIOperators[termOptionsType];
      const termUI = '"' + term.reduce((acc, next) => (acc + '" ' + termUIOperator + ' "' + next.toString())).toUpperCase() + '"';
      resultUI.push(
        <div className="result-box">
          {attUI + ' ' + verbUI + ' ' + termUI}
        </div>
      );
    }
    else if (type === 'opr') {
      const oprUI = logic.verb === 'and' ? 'E' : (logic.verb === 'or' ? 'OU' : '');
      resultUI.push(
        <div className="logic-box">
          {oprUI}
        </div>
      )
    }
  });

  return resultUI;
}

const inputBasedOnOperator = ({ inputBasedOnOperator, option }, handleChangeOption, options = null) => ({
  selectMany: (
    <Input
      type="select"
      name="filterInput"
      id="filterInput"
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
      name="filterInput"
      id="filterInput"
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
      name="filterInput"
      id="filterInput"
      value={option}
      onChange={handleChangeOption}
    />
  ),
  number: (
    <Input
      type="text"
      name="filterInput"
      id="filterInput"
      value={option}
      onChange={handleChangeOption}
    />
  ),
  twoNumbers: (
    <div
      style={{ display: "flex", flexDirection: "column", alignItems: "center" }}
    >
      <Input
        type="text"
        name="filterInput"
        id="filterInput"
        style={{ marginBottom: "5px" }}
      />
      <span>E</span>
      <Input
        type="text"
        name="filterInput"
        id="filterInput"
        style={{ marginTop: "5px" }}
      />
    </div>
  ),
}[inputBasedOnOperator]);

class ModalCreateFilter extends Component {
  constructor(props) {
    super(props);
    this.state = {
      filterName: '',
      attribute: null,
      operator: null,
      option: null,
      inputBasedOnOperator: 'nothing',
      currentFilterLogic: [],
    };
  }

  handleChangeOption = (event) => {
    console.log('Handle: ', event.target)
    const { value } = event.target;
    this.setState({
      option: value,
    });
  }

  handleAttributeSelectClick = (event) => {
    this.setState(
      {
        attribute: event.target.value,
        operator: null,
        inputBasedOnOperator: 'nothing',
        option: null,
      }
    );
  }

  handleInputSelectClick = (type) => (event) => {
    this.setState({
      operator: event.target.value,
      inputBasedOnOperator: filterOperations[type][event.target.value].optionsType,
    });
  }

  cleanState = () => {
    this.setState({
      filterName: '',
      attribute: null,
      operator: null,
      option: null,
      inputBasedOnOperator: 'nothing',
    });
  }

  cleanFilter = () => {
    this.setState({
      currentFilterLogic: [],
    });
  }

  buildFilter = (attributes) => () => {
    const { attribute, operator, option } = this.state;
    let term = [];

    if (!attribute || attribute === '') {
      return;
    }
    if (!operator || operator === '') {
      return;
    }
    if (!option || option === '' || option === []) {
      return;
    }

    if (attributes[attribute].type === 'text') {
      option.trim().split(" ").forEach(element => {
        if (element.length > 0) term.push(element);
      });
    } else {
      term.push(option);
    }

    const newLogic = {
      type: (operator === 'and' || operator === 'or' ? 'opr' : 'att'),
      attribute,
      verb: operator,
      term,
    };

    this.setState((prevState) => ({
      currentFilterLogic: [...prevState.currentFilterLogic, newLogic],
    }), () => { this.cleanState() });
  }

  render() {
    const {
      toggle,
      modal,
      attributes,
      filterLogic
    } = this.props;

    console.log("Attributes: ", attributes);

    const type = this.state.attribute && attributes[this.state.attribute].type;

    console.log('State: ', this.state);

    const listDropdown = Object.keys(attributes);

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
                <CustomInput disabled type="switch" id="saveSwitch" name="saveSwitch" label="Aplicar filtro sem salvar" />
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
                  <Input
                    type="select"
                    name="attribute"
                    id="attribute"
                    onChange={this.handleAttributeSelectClick}
                  >
                    <option value selected={!this.state.attribute} style={{ display: 'none' }}></option>
                    {attributes && listDropdown.map((option) => (
                      <option value={option}>
                        {attributes[option].name}
                      </option>
                    ))}
                  </Input>
                </Col>
              </FormGroup>
              <FormGroup row style={{ minHeight: "93px" }}>
                <Col sm={4} style={{ margin: "auto 0" }}>
                  <Input
                    style={{ textAlign: "center" }}
                    value={this.state.attribute ? attributes[this.state.attribute].name : ''}
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
                    onChange={this.handleInputSelectClick(type)}
                  >
                    <option value selected={!this.state.operator} style={{ display: 'none' }}></option>
                    {this.state.attribute && Object.keys(filterOperations[type]).map((option) => (
                      <option value={option}>
                        {filterOperations[type][option].description}
                      </option>
                    ))}
                  </Input>
                </Col>
                <Col sm={4} style={{ margin: "auto 0" }}>
                  {inputBasedOnOperator(this.state, this.handleChangeOption)}
                </Col>
              </FormGroup>
              <Button color="primary" onClick={this.buildFilter(attributes)}>Adicionar</Button>
              <Button color="warning" style={{ marginLeft: "10px" }} onClick={() => { this.cleanState(); }}>Limpar</Button>
              <Button color="danger" style={{ marginLeft: "10px" }} onClick={() => { this.cleanState(); this.cleanFilter(); }}>Limpar Resultado</Button>
            </div>
          </div>
          <div className='create-filter-container'>
            <div className={'filter-container-title'}>
              <div className="filter-title">
                Resultado
              </div>
              <div className="filter-container-body">
                <div className="result-container">
                  {filterResultUI(this.state.currentFilterLogic, attributes, filterOperations)}
                </div>
              </div>
            </div>
          </div>
        </ModalBody>
        <ModalFooter className={'filter-footer'}>
          <Button color="success" onClick={() => { this.cleanState(); }}>Criar Filtro</Button>
          <Button color="danger" onClick={() => { toggle(); this.cleanState(); }}>Cancelar</Button>
        </ModalFooter>
      </Modal>
    );
  }
}

export default ModalCreateFilter;