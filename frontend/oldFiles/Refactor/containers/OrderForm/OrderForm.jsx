import React, { Component } from "react";
import { Row, Col, Card, CardBody, CardHeader, CardFooter, Button, } from 'reactstrap';
import _Form from '../../components/Form';
import _Spinner from '../../components/Spinner';
import BackButton from '../../components/BackButton';
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { qQuery, qConfig, mQuery, mConfig, getVariables } from "./graphql";
import getFiles from '../../utils/getFiles';
import AssetSelect from "../AssetSelect";
import SupplySelect from "../SupplySelect";

class OrderForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      assets: [],
      supplies: [],
      qty: [],
    }
    this.innerRef = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.addAsset = this.addAsset.bind(this);
    this.removeAsset = this.removeAsset.bind(this);
    this.addSupply = this.addSupply.bind(this);
    this.removeSupply = this.removeSupply.bind(this);
    this.handleQty = this.handleQty.bind(this);
  }

  shouldComponentUpdate(nextProps, nextState){
    if(
      nextProps.loading !== this.props.loading ||
      nextState.assets !== this.state.assets ||
      nextState.supplies !== this.state.supplies ||
      nextState.contractId !== this.state.contractId
    ){
      return true;
    } else {
      return false;
    }
  }

  handleChange(event) {
    event.persist();
    const name = event.target.name;
    const value = event.target.value;
    if(value.length === 0){
      this.setState({ [name]: null });
    } else if(name === 'contractId'){
      this.setState({ supplies: [], qty: [], [name]: value });
    } else {
      this.setState({ [name]: value });
    }
  }

  addAsset(event){
    event.persist();
    event.preventDefault();
    const name = event.target.name;
    this.setState(prevState => {
      if(!prevState.assets.includes(Number(name))){
        return {
          assets: [...prevState.assets, Number(name)],
        };
      }
    });
  }

  removeAsset(event){
    event.persist();
    event.preventDefault();
    const newAssets = [...this.state.assets];
    const name = event.target.name;
    const i = this.state.assets.findIndex(el => el === Number(name));
    newAssets.splice(i,1);
    this.setState({ assets: newAssets, });
  }

  addSupply(event){
    event.persist();
    event.preventDefault();
    const name = event.target.name;
    this.setState(prevState => {
      if(!prevState.supplies.includes(Number(name))){
        return {
          supplies: [...prevState.supplies, Number(name)],
          qty: [...prevState.qty, null],
        };
      }
    });
  }

  removeSupply(event){
    event.persist();
    event.preventDefault();
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
                  <BackButton />
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
                onCancel={this.handleCancel}
                loading={loading}
              />
              </Col>
              <Col sm="12" md="6">
                <AssetSelect
                  queryCondition={null}
                  selected={this.state.assets}
                  addItem={this.addAsset}
                  removeItem={this.removeAsset}
                  handleQty={() => {}}
                />
                <SupplySelect
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
