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
  CustomInput,
  ListGroup,
  ListGroupItem,
} from "reactstrap";
import SingleInputWithDropdown from "../Forms/SingleInputWithDropdown";

import "./ModalCreateFilter.css";

const condicionalOperator = {
  and: 'Condicional E',
  or: 'Condicional OU'
};

const filterOperations = {
  option: {
    sameTo: { description: 'igual a', optionsType: 'selectMany' },
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
    // between: { description: 'entre', optionsType: 'twoNumbers' },
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
      let termUI = "";
      if (termOptionsType !== 'nothing') {
        termUI = '"' + term.reduce((acc, next) => (acc + '" ' + termUIOperator + ' "' + next.toString())).toUpperCase() + '"';
      }
      resultUI.push(
        <div className="result-box">
          {attUI + ' ' + verbUI + ' ' + termUI}
        </div>
      );
    }
    else if (type === 'opr') {
      const oprUI = attribute === 'and' ? 'E' : (attribute === 'or' ? 'OU' : '');
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
  // twoNumbers: (
  //   <div
  //     style={{ display: "flex", flexDirection: "column", alignItems: "center" }}
  //   >
  //     <Input
  //       type="text"
  //       name="filterInput"
  //       id="filterInput"
  //       style={{ marginBottom: "5px" }}
  //     />
  //     <span>E</span>
  //     <Input
  //       type="text"
  //       name="filterInput"
  //       id="filterInput"
  //       style={{ marginTop: "5px" }}
  //     />
  //   </div>
  // ),
}[inputBasedOnOperator]);

class ApplyFilter extends Component {
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
      attribute: null,
      operator: null,
      option: null,
      inputBasedOnOperator: 'nothing',
    });
  }

  cleanFilter = () => {
    this.setState({
      filterName: '',
      currentFilterLogic: [],
    });
  }

  buildFilter = (attributes) => () => {
    const { attribute, operator, option } = this.state;

    let term = [];

    if (!attribute || attribute === '') {
      return;
    }
    if ((!operator || operator === '') && !condicionalOperator[attribute]) {
      return;
    }

    if (attribute !== 'and' && attribute !== 'or') {
      const { type } = attributes[attribute];
      const { optionsType } = filterOperations[type][operator];

      if (optionsType !== 'nothing' && (!option || option === '' || option === [])) {
        return;
      }

      if (optionsType !== 'nothing' && attributes[attribute].type === 'text') {
        option.trim().split(" ").forEach(element => {
          if (element.length > 0) term.push(element);
        });
      } else {
        term.push(option);
      }
    }

    const newLogic = {
      type: (attribute === 'and' || attribute === 'or' ? 'opr' : 'att'),
      attribute,
      verb: operator,
      term,
    };

    this.setState((prevState) => ({
      currentFilterLogic: [...prevState.currentFilterLogic, newLogic],
    }), () => { this.cleanState() });
  }

  fixFilterAndUpdate = (updateFunction, toggleFunction) => () => {
    const { currentFilterLogic, filterName } = this.state;
    console.log("Filter Name: ", filterName);
    let finalFilter = null;
    const lastLogic = currentFilterLogic.slice(-1)[0];
    if (lastLogic && lastLogic.type === 'opr') {
      finalFilter = currentFilterLogic.slice(0, -1);
    } else {
      finalFilter = currentFilterLogic;
    }
    updateFunction(finalFilter, filterName);
    this.cleanFilter();
    this.cleanState();
    toggleFunction();
  }

  handleChangeOnName = (event) => {
    const { value } = event.target;
    this.setState({
      filterName: value,
    });
  }

  render() {
    const {
      toggle,
      modal,
      attributes,
      updateCurrentFilter
    } = this.props;

    let type = this.state.attribute && attributes[this.state.attribute] && attributes[this.state.attribute].type;
    if (!type) {
      type = "opr"
    }

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
                <h4>Aplicar Filtro</h4>
                <div className="dash-subtitle text-truncate">
                  Lista de filtros salvos
                </div>
              </div>
            </Col>
            <Col md="4" xs="6" className="container-left">
              <Button
                onClick={() => { }}
                className="ghost-button" style={{ width: "auto", height: "38px", padding: "8px 40px" }}>Criar Filtros</Button>
            </Col>
          </Row>
        </div>
        <ModalBody>
          <FormGroup row>
            <Label for="filterName" sm={2}>Nome</Label>
            <Col sm={10}>
              <Input
                type="text"
                name="filterName"
                id="filterName"
                value={this.state.filterName}
                disabled
              />
            </Col>
          </FormGroup>
          <div className='create-filter-container'>
            <div className={'filter-container-title'}>
              <div className="filter-title">
                Escolha seu Filtro
              </div>
            </div>
            <div className="filter-container-body" style={{ paddingBottom: "20px" }}>
              <div className="filter-apply-table">
                <ListGroup style={{ borderLeft: "none" }}>
                  <ListGroupItem tag="button" action>
                    <Row>
                      <Col xs={1}><b>Filtro:</b></Col>
                      <Col xs={5}>Sem Filtro</Col>
                      <Col xs={1}><b>Autor:</b></Col>
                      <Col xs={5}>Pedro Serafim</Col>
                    </Row>
                  </ListGroupItem>
                  <ListGroupItem className={'filter-active-filter'} tag="button" action>
                    <Row>
                      <Col xs={1}><b>Filtro:</b></Col>
                      <Col xs={5}>Edifícios - Blocos de Apoio</Col>
                      <Col xs={1}><b>Autor:</b></Col>
                      <Col xs={5}>Pedro Serafim</Col>
                    </Row>
                  </ListGroupItem>
                  <ListGroupItem tag="button" action>
                    <Row>
                      <Col xs={1}><b>Filtro:</b></Col>
                      <Col xs={5}>Edifícios -  Áreas Técnicas</Col>
                      <Col xs={1}><b>Autor:</b></Col>
                      <Col xs={5}>Pedro Serafim</Col>
                    </Row>
                  </ListGroupItem>
                  <ListGroupItem tag="button" action>
                    <Row>
                      <Col xs={1}><b>Filtro:</b></Col>
                      <Col xs={5}>Apartamentos Funcionais</Col>
                      <Col xs={1}><b>Autor:</b></Col>
                      <Col xs={5}>Pedro Serafim</Col>
                    </Row>
                  </ListGroupItem>
                  <ListGroupItem tag="button" action>
                    <Row>
                      <Col xs={1}><b>Filtro:</b></Col>
                      <Col xs={5}>Edifícios- Gráfica</Col>
                      <Col xs={1}><b>Autor:</b></Col>
                      <Col xs={5}>Pedro Serafim</Col>
                    </Row>
                  </ListGroupItem>
                  <ListGroupItem tag="button" action>
                    <Row>
                      <Col xs={1}><b>Filtro:</b></Col>
                      <Col xs={5}>Edifícios- Anexo I</Col>
                      <Col xs={1}><b>Autor:</b></Col>
                      <Col xs={5}>Pedro Serafim</Col>
                    </Row>
                  </ListGroupItem>
                  <ListGroupItem tag="button" action>
                    <Row>
                      <Col xs={1}><b>Filtro:</b></Col>
                      <Col xs={5}>Edifícios- Anexo II</Col>
                      <Col xs={1}><b>Autor:</b></Col>
                      <Col xs={5}>Pedro Serafim</Col>
                    </Row>
                  </ListGroupItem>
                </ListGroup>
              </div>
            </div>
          </div>
          <div className='create-filter-container'>
            <div className={'filter-container-title'}>
              <div className="filter-title">
                Lógica
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
          <Button color="success" onClick={this.fixFilterAndUpdate(updateCurrentFilter, toggle)}>Aplicar Filtro</Button>
          <Button color="danger" onClick={() => { toggle(); this.cleanState(); this.cleanFilter(); }}>Fechar</Button>
        </ModalFooter>
      </Modal>
    );
  }
}

export default ApplyFilter;