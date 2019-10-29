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
  constructor(props) {
    super(props);
    state = {
      modal: 'false'
    };
  }

  toggle() {
    this.setState((prevState) => ({
      modal: !prevState.modal
    }));
  }

  render() {
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