import React, { Component } from 'react';
import { Button } from 'reactstrap';
import './PaneTitle.css'

class PaneTitle extends Component {
  state = {  }
  render() { 
    const { actionButtons } = this.props;
    console.log("Buttons: ", actionButtons);
    return ( 
      <div 
          className='action-container'
        >
          <div className="action__text">Tramitar Tarefa / Alterar Status</div>
          <div className='action__buttons'>
            {actionButtons.map(button => (
              <Button color={button.color} size="sm" style={{marginRight: "10px" }}>
                {button.name}
              </Button>
            ))}
          </div>
        </div>
     );
  }
}
 
export default PaneTitle;