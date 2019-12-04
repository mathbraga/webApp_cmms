import React, { Component } from "react";
import { Row, Col, Card, CardBody, CardHeader,   CardFooter, Button, } from 'reactstrap';
import _Form from '../../components/Form';
import _Spinner from '../../components/Spinner';
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { qQuery, qConfig, mQuery, mConfig, getVariables } from "./graphql";
import getFiles from '../../utils/getFiles';
import getMultipleSelect from '../../utils/getMultipleSelect';
import MultipleSelect from "../MultipleSelect";

class OrderForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      supplies: [],
      qty: [],
    }
    this.innerRef = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleCancel = this.handleCancel.bind(this);
    this.addSupply = this.addSupply.bind(this);
    this.removeSupply = this.removeSupply.bind(this);
    this.handleQty = this.handleQty.bind(this);
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
        this.setState({ supplies: [], qty: [] })
      }
      this.setState({ [name]: value });
    }
  }

  addSupply(event){
    event.persist();
    event.preventDefault();
    const name = event.target.name;
    this.setState(prevState => {
      if(!prevState.supplies.includes(Number(name))){
        return {
          supplies: [...prevState.supplies, Number(name)],//.sort((a, b) => (a - b)),
          qty: [...prevState.qty, null],
        };
      }
    });
  }

  removeSupply(event){
    event.persist();
    event.preventDefault();
    console.log(event.target.name);
    const newSupplies = [...this.state.supplies];
    const newQty = [...this.state.qty];
    const name = event.target.name;
    const i = this.state.supplies.findIndex(el => el === Number(name));
    newSupplies.splice(i,1);
    newQty.splice(i,1);
    this.setState({ supplies: newSupplies, qty: newQty });
  }

  handleQty(event){
    event.persist();
    const name = event.target.name;
    const value = event.target.value;
    const newQty = [...this.state.qty];
    newQty[name] = value ===  '' ? null : Number(value.replace(',', '.'));
    this.setState({ qty: newQty });
  }

  handleCancel(){
    this.props.history.goBack();
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
                  <Button
                    onClick={this.handleCancel}
                  >X</Button>
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
                onCancel={this.handleCancel}
                loading={loading}
              />
              </Col>
              <Col sm="12" md="6">
                <MultipleSelect
                  queryCondition={this.state.contractId}
                  selected={this.state.supplies}
                  addItem={this.addSupply}
                  removeItem={this.removeSupply}
                  handleQty={this.handleQty}
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
