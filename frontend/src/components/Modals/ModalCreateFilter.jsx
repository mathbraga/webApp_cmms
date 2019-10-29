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
  Input
} from "reactstrap";
import AssetCard from "../Cards/AssetCard";

import "./ModalCreateFilter.css";

class ModalCreateFilter extends Component {

  render() {
    const { toggle, modal } = this.props;
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
                className="ghost-button" style={{ width: "auto", height: "38px", padding: "8px 40px" }}>Filtros</Button>
            </Col>
          </Row>
        </div>
        <ModalBody>
          <Form>
            <FormGroup row>
              <Label for="filterName" sm={2}>Nome</Label>
              <Col sm={10}>
                <Input type="text" name="filterName" id="filterName" />
              </Col>
            </FormGroup>
          </Form>
        </ModalBody>
        <ModalFooter className={'filter-footer'}>
          Hey
        </ModalFooter>
      </Modal>
    );
  }
}

export default ModalCreateFilter;