import React, { Component } from 'react';
import "./FormGroup.css"

class FormGroup extends Component {
  render() { 
    const { sectionTitle, children } = this.props;
    return ( 
      <>
        <h1 className="form-group__title">{sectionTitle}</h1>
        {children}
      </>
     );
  }
}
 
export default FormGroup;