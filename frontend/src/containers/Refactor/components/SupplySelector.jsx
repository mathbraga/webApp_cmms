import React, { Component } from "react";
import {
  Badge,
  Table,
  Button,
  Card,
  CardBody,
  CardHeader,
  Col,
  Form,
  FormGroup,
  Input,
  Label,
  Row,
} from 'reactstrap';
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';
import getSupplyList from '../utils/getSupplyList';

class SupplySelector extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: [],
      qty: [],
    }
    this.addSupply = this.addSupply.bind(this);
    this.removeSupply = this.removeSupply.bind(this);
    this.handleQty = this.handleQty.bind(this);
  }

  addSupply(event){
    event.persist();
    event.preventDefault();
    const name = event.target.name;
    this.setState(prevState => {
      if(!prevState.selected.includes(Number(name))){
        return {
          selected: [...prevState.selected, Number(name)],//.sort((a, b) => (a - b)),
          qty: [...prevState.qty, null],
        };
      }
    });
  }

  removeSupply(event){
    event.persist();
    event.preventDefault();
    console.log(event.target.name);
    const newSelected = [...this.state.selected];
    const newQty = [...this.state.qty];
    const name = event.target.name;
    const i = this.state.selected.findIndex(el => el === Number(name));
    newSelected.splice(i,1);
    newQty.splice(i,1);
    this.setState({ selected: newSelected, qty: newQty });
  }

  handleQty(event){
    event.persist();
    const name = event.target.name;
    const value = event.target.value;
    const newQty = [...this.state.qty];
    newQty[name] = value ===  '' ? null : Number(value);
    this.setState({ qty: newQty });
  }
  

  render() {

    const { contractId, options, selected, onChange } = this.props;
    let idx = -1;

    return (
      <Card>
        <CardHeader>{"Materiais e Serviços"}</CardHeader>
        <CardBody>
          <Table hover borderless size='sm' style={{display: 'block', height: '10rem', overflow: 'scroll'}}>
            <tbody>
              {options.map((supply, i) => (
                <tr key={i}>
                  <td>
                    <Badge
                      size='sm'
                      name={supply.supplyId}
                      href={"#"}
                      color='success'
                      onClick={this.addSupply}
                    >+</Badge>
                    &nbsp;&nbsp;
                    {supply.supplySf + ' - ' + supply.name}
                  </td>
                </tr>
              ))}
            </tbody>
          </Table>
          <hr/>


          <p style={{textAlign: 'right'}}><em>Nenhum item selecionado</em></p>
          <p style={{textAlign: 'right'}}><em>Defina as quantidades</em></p>



          <Table hover borderless size='sm'>
            <tbody>
              {this.state.selected.map((supplyId, i) => {
                const sup = options.find(supply => supplyId === supply.supplyId)
                  idx++;
                  return (
                    <tr key={sup.supplyId}>
                  <td>
                    <Badge
                      name={sup.supplyId}
                      href={"#"}
                      color='danger'
                      onClick={this.removeSupply}
                    >X
                    </Badge>
                    &nbsp;&nbsp;
                    {sup.supplySf + ' - ' + sup.name}
                  </td>
                  <td style={{width: '5rem'}}>
                  <Input
                    style={{textAlign: 'right'}}
                    type='text'
                    name={idx}
                    bsSize='sm'
                    placeholder={sup.unit}
                    onBlur={this.handleQty}
                  ></Input>
                  </td>
                </tr>
                  )
              })}
            </tbody>
          </Table>
        </CardBody>
      </Card>
    );
  }
}

export const qQuery = gql`
  query ($contractId: Int) {
    supplies: allSuppliesLists(condition: {contractId: $contractId}) {
      nodes {
        supplyId
        supplySf
        name
        unit
      }
    }
  }
`;

export const qConfig = {
  options: props => ({
    variables: {contractId: 1},
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  props: props => {
    
    let options;

    if(props.data.networkStatus === 7){
      options = props.data.supplies.nodes;
    }

    return {
      error: props.data.error,
      loading: props.data.loading,
      options: options ? options : [],
    }
  },
  skip: false,//props => !props.contractId,
  // name: ,
  // withRef: ,
  // alias: ,
};


export default graphql(qQuery, qConfig)(SupplySelector);
