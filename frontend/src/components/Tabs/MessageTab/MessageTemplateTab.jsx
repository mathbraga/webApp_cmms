import React, { Component } from 'react';
import DescriptionTable from '../../Descriptions/DescriptionTable';
import { InputGroup, Button, InputGroupAddon, Input, Collapse, Card, CardBody } from 'reactstrap';
import "./MessageTemplateTab.css"

class MessageTemplateTab extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isOpen: false
    };

    this.setCollapseState = this.setCollapseState.bind(this);
  }

  setCollapseState(){
    this.setState({ isOpen: !this.state.isOpen })
  }

  render() {
    const { data } = this.props; //temporarily unused
    const isOpen = this.state.isOpen;
    const setCollapseState = this.setCollapseState;

    return (
      <>
        <DescriptionTable
            title="Mensagens"
        />
        <div className="message__container">
          <div className="message__content">
              <div className="message__author">
                <div>
                  <div className="message__icon"></div>
                  <div className="message__name">John Doe</div>
                </div>
                <div className="text-muted message__date">Mar 26, 2020 - 14h56</div>
              </div>
              <div className="message__text">
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio urna, posuere ut quam id, facilisis porttitor neque. Nullam finibus neque sed lorem vehicula, ut dignissim mauris sagittis. Sed in aliquam eros. Nunc semper dui a vulputate dignissim. Duis vestibulum ac neque vel ultrices. Vestibulum porttitor sapien nec metus dictum.
              </div>
          </div>
          <button className="comment__button" onClick={setCollapseState}>
            <i className="comment__icon fa fa-comment"></i>
            <div className="comment__action">Comentar</div>
          </button>
          <div className="comment__bubble__container comment__bubble">
            <div className="comment__bubble__content">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio urna, posuere ut quam id, facilisis porttitor neque. Nullam finibus neque sed lorem vehicula, ut dignissim mauris sagittis.
            </div>
          </div>
        </div>
          <div className="comment__container">
          </div>
          <Collapse isOpen={isOpen}>
            <div className="comment__text__area">
              <Input placeholder="Digitar mensagem." className="comment__text__box" type="textarea"/>
              <Button className="comment__text__action" color="primary">Enviar</Button>
            </div>
          </Collapse>
          {/* <div className="comment__container">
          <InputGroup>
            <Input/>
            <InputGroupAddon addon="append">
              <Button color="primary">Comentar</Button>
            </InputGroupAddon>
          </InputGroup>
          </div> */}
      </>
    );
  }
}

export default MessageTemplateTab;