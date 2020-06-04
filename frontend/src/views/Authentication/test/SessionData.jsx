import React, { Component } from "react";
import { Alert, Button, Card, CardBody, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import { withProps, withQuery, withGraphQL } from '../../../hocs';
import withDataAccess from '../utils/withDataAccess';
import props from '../utils/props';
import { compose } from "redux";

class SessionData extends Component{
    constructor(props){
        super(props);
    }

    render(){
        const data = this.props.data;

        return(
            <div>{data}</div>
        )
    }
}

// export default withDataAccess(SessionData);

export default compose(
  withProps(props),
  withGraphQL,
  withQuery,
  withDataAccess
)(SessionData);