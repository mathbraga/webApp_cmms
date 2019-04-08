import React from 'react';
import { Badge, Tooltip } from 'reactstrap';

class BadgeWithTooltips extends React.Component {
  constructor(props) {
    super(props);

    this.toggle = this.toggle.bind(this);
    this.state = {
      tooltipOpen: false
    };
  }

  toggle() {
    this.setState({
      tooltipOpen: !this.state.tooltipOpen
    });
  }

   render() {
    return (
      <span>
        <Badge color={this.props.color} id={'Tooltip-' + this.props.id}>
          {this.props.situation}
        </Badge>
        <Tooltip autohide={false} placement="right" isOpen={this.state.tooltipOpen} target={'Tooltip-' + this.props.id} toggle={this.toggle}>
          <strong>{this.props.name}</strong>
          <br/>
          <br/>
          <strong>Observações:</strong>
          <br/>
          <p style={{ "text-align": "justify" }}>{this.props.obs}</p>
          <strong>Faixa de normalidade:</strong>
          <br/>
          {this.props.expected}
        </Tooltip>
      </span>
    );
  }
}

export default BadgeWithTooltips;
