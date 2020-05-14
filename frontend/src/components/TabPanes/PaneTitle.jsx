import React, { Component } from 'react';
import './PaneTitle.css'

class PaneTitle extends Component {
  state = {  }
  render() { 
    return ( 
      <div 
          className='action-container'
        >
          <div className="action__text">Tramitar Tarefa / Alterar Status</div>
          <div className='action__buttons'>
            <Button color="success" size="sm" style={{ marginRight: "10px" }}>
              Tramitar
            </Button>
            <Button color="primary" size="sm">
              Alterar Status
            </Button>
          </div>
        </div>
     );
  }
}
 
export default PaneTitle;