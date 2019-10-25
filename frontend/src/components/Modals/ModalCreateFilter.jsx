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
        <div>Hey</div>
      </Modal>
    );
  }
}

export default ModalCreateFilter;