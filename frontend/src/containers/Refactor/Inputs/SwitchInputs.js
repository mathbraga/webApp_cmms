import React, { Component } from "react";
import InputText from './InputText';
import InputSelect from './InputSelect';
import InputDate from './InputDate'
import InputFiles from './InputFiles';

class SwitchInputs extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  renderSwitch(props) {

    const { input, innerRef, onChange } = props;

    switch(input.type) {
      case 'text':
        return <InputText input={input} onChange={onChange}/>;
      case 'select':
        return <InputSelect input={input} onChange={onChange}/>;
      case 'date':
        return <InputDate input={input} onChange={onChange}/>;
      case 'file':
        return <InputFiles input={input} onChange={onChange} innerRef={innerRef}/>;
      default:
        return null;
    }
  }

  render() {

    return (
      <React.Fragment>
        {this.renderSwitch(this.props)}
      </React.Fragment>
    );
  }
}

export default SwitchInputs;
