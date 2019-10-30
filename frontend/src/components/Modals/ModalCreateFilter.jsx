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
  choice: [
    { name: 'equalTo', description: 'igual a', optionsType: 'selectMany' },
    { name: 'different', description: 'diferente de', optionsType: 'selectMany' },
    { name: 'notNull', description: 'não nulo', optionsType: 'nothing' },
    { name: 'null', description: 'nulo', optionsType: 'nothing' }
  ],
  text: [
    { name: 'include', description: 'contém', optionsType: 'text' },
    { name: 'notInclude', description: 'não contém', optionsType: 'text' },
    { name: 'notNull', description: 'não nulo', optionsType: 'nothing' },
    { name: 'null', description: 'nulo', optionsType: 'nothing' }
  ],
  number: [
    { name: 'equalTo', description: 'igual a', optionsType: 'number' },
    { name: 'greaterThan', description: 'maior que', optionsType: 'number' },
    { name: 'lowerThan', description: 'menor que', optionsType: 'number' },
    { name: 'different', description: 'diferente de', optionsType: 'number' },
    { name: 'between', description: 'entre', optionsType: 'twoNumbers' },
  ],
};

class ModalCreateFilter extends Component {

  render() {
    const {
      toggle,
      modal,
      attributes
    } = this.props;
    const listDropdown = attributes.map(attribute => (
      { id: attribute.attribute, text: attribute.name, subtext: '' }
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
                  />
                </Col>
              </FormGroup>
              <FormGroup row>
                <Col sm={4} style={{ margin: "auto 0" }}>
                  <Input disabled type="text" name="attribute" id="attribute" />
                </Col>
                <Col sm={4} style={{ margin: "auto 0" }}>
                  <Input type="select" name="attribute" id="attribute" >
                    {attributes.map(attribute => (
                      <option>{attribute.name}</option>
                    ))}
                  </Input>
                </Col>
                <Col sm={4}>
                  <Input type="select" name="attribute" id="attribute" multiple >
                    <option>A</option>
                    <option>B</option>
                    <option>C</option>
                    <option>D</option>
                    <option>E</option>
                    <option>F</option>
                    <option>G</option>
                    <option>H</option>
                    <option>I</option>
                    <option>J</option>
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