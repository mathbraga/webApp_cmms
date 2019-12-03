import React, { Component } from "react";
import { Row, Col, Card, CardBody, CardHeader,   CardFooter, Button, } from 'reactstrap';
import _Form from '../../components/Form';
import _Spinner from '../../components/Spinner';
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { qQuery, qConfig, mQuery, mConfig, getVariables } from "./graphql";
import getFiles from '../../utils/getFiles';
import getMultipleSelect from '../../utils/getMultipleSelect';
import getSupplyList from '../../utils/getSupplyList';
import getSuppliesQty from '../../utils/getSuppliesQty';
import SupplySelector from "../../components/SupplySelector";

class OrderForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      supplies: null,
      qty: null,
    }
    this.innerRef = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    event.persist();
    // console.log(event.target.options);
    const name = event.target.name;
    const value = event.target.value;
    const options = event.target.options;
    if (value.length === 0)
      return this.setState({ [name]: null });
    if (name === 'assets'){
      this.setState({ assets: getMultipleSelect(options), });
    // else if (name === 'supplies'){
    //   this.setState({ supplies: getMultipleSelect(options), });
    // } else if (name === 'supply-qty'){
    //   // this.setState(prevState => ({ qty: getSuppliesQty(options), }));
    } else {
      if(name === 'contractId'){
        console.log('here')
        this.setState({ supplies: null})
      }
      this.setState({ [name]: value });
    }
  }

  handleSupplies(event){
    event.persist();
    const name = event.target.name;
    const options = event.target.options;
    if (name === 'supplies'){
    this.setState({ supplies: getMultipleSelect(options), });
    } else if (name === 'supply-qty'){
      this.setState(prevState => ({ qty: getSuppliesQty(event), }));
    }
  }

  handleSubmit(event) {
    event.preventDefault();
    return this.props.mutate({
      variables: {
        ...getVariables(this.state),
        ...getFiles(this.innerRef.current.files)
      }
    });
  }

  render() {

    const { error, loading, form } = this.props;

    if(error) return <p>{JSON.stringify(error)}</p>;

    if(loading) return <_Spinner />;
    
    return (
      <div className="animated fadeIn">
        <Card>
          <CardHeader>
            <Row>
              <Col><h3>{form.title}</h3></Col>
              <Col>
                <div style={{textAlign: 'right'}}>
                  <Button>X</Button>
                </div></Col>
            </Row>
          </CardHeader>
          <CardBody>
            <Row>
              <Col sm="12" md="6">
              <_Form
                form={form}
                innerRef={this.innerRef}
                onChange={this.handleChange}
                onSubmit={this.handleSubmit}
                loading={loading}
              />
              </Col>
              <Col sm="12" md="6">
                <SupplySelector
                  contractId={this.state.contractId}
                  selected={this.state.supplies ? this.state.supplies : null}
                  onChange={this.handleChange}
                />
              </Col>
            </Row>
          </CardBody>
          <CardFooter>
                  <Button
                    block
                    disabled={loading}
                    type="button"
                    color="primary"
                    onClick={this.handleSubmit}
                  >{form.button}
                  </Button>
          </CardFooter>
        </Card>
      </div>
    );
  }
}

export default compose(
  graphql(qQuery, qConfig),
  graphql(mQuery, mConfig)
)(OrderForm);
