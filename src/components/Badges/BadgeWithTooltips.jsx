import React from "react";
import { Badge, Tooltip } from "reactstrap";
import getMetersIDs from "../../utils/consumptionMonitor/getMetersIDs";

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
    let metersIDs = [];
    if (this.props.chosenMeter === "199") {
      metersIDs = getMetersIDs(this.props.problem, this.props.meters);
    }

    return (
      <span>
        <Badge color={this.props.color} id={"Tooltip-" + this.props.id}>
          {this.props.situation}
        </Badge>
        <Tooltip
          autohide={false}
          placement="right"
          isOpen={this.state.tooltipOpen}
          target={"Tooltip-" + this.props.id}
          toggle={this.toggle}
        >
          <strong>{this.props.name}</strong>
          <br />
          <br />
          <strong>Observações:</strong>
          <br />
          <p style={{ "textAlign": "justify" }}>{this.props.obs}</p>
          <strong>Faixa de normalidade:</strong>
          <br />
          {this.props.expected}
          {metersIDs.length > 0 && (
            <>
              <br />
              <p style={{ "textAlign": "justify" }} />
              <strong>Verificar medidor(es):</strong>
              {metersIDs.map(meterID => (
                <React.Fragment key={meterID}>
                  <br />
                  <>{meterID}</>
                </React.Fragment>
              ))}
            </>
          )}
        </Tooltip>
      </span>
    );
  }
}

export default BadgeWithTooltips;
