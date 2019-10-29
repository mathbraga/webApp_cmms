import React, { Component } from "react";
import {
  Row,
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
} from "reactstrap";

class ModalCreateFilter extends Component {

  render() {
    const { toggle, modal } = this.props;
    return (
      <Modal isOpen={modal} toggle={toggle}>
        <ModalHeader toggle={toggle}>
          Criar Filtro
        </ModalHeader>
        <ModalBody>
          <div>Hey</div>
        </ModalBody>
        <ModalFooter>
          <Button color="primary" onClick={toggle}>Aplicar</Button>{' '}
          <Button color="secondary" onClick={toggle}>Cancelar</Button>
        </ModalFooter>
      </Modal>
    );
  }
}

export default ModalCreateFilter;