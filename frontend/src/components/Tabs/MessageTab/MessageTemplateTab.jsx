import React, { Component } from 'react';
import DescriptionTable from '../../Descriptions/DescriptionTable';
import { InputGroup, Button, InputGroupAddon, Input } from 'reactstrap';
import "./MessageTemplateTab.css"

class MessageTemplateTab extends Component {
  render() {
    const { data } = this.props; //temporarily unused

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
        </div>
        <div className="comment__container">
          <InputGroup>
            <Input/>
            <InputGroupAddon addon="append">
              <Button color="primary">Comentar</Button>
            </InputGroupAddon>
          </InputGroup>
        </div>
      </>
    );
  }
}

export default MessageTemplateTab;