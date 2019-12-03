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
    }
    this.addSupply = this.addSupply.bind(this);
    this.removeSupply = this.removeSupply.bind(this);
    this.handleQty = this.handleQty.bind(this);
  }

  addSupply(event){
    event.persist();
    event.preventDefault();
    const name = event.target.name;
    const value = event.target.value;
    // console.log(event)
    this.setState(prevState => {
      if(prevState.selected.includes(Number(name))){
        return {
          selected: prevState.selected,
        };
      } else {
        return {
          selected: [...prevState.selected, Number(name)]
        };
      }
    });
  }

  removeSupply(event){
    event.persist();
    event.preventDefault();
    console.log(event.target.name);
    const newSelected = [...this.state.selected];
    const name = event.target.name;
    const i = this.state.selected.findIndex(el => el === Number(name));
    newSelected.splice(i,1);
    this.setState({ selected: newSelected });
  }

  handleQty(event){
    event.persist();
    const i = event.target.name;
    const value = event.target.value;
  }
  

  render() {

    const { contractId, options, selected, onChange } = this.props;

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
                      // value={supply}
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
              {options.map((supply, i) => {
                if(this.state.selected.includes(supply.supplyId)){
                  return (
                    <tr key={supply.supplyId}>
                  <td>
                    <Badge
                      name={supply.supplyId}
                      value={supply}
                      href={"#"}
                      color='danger'
                      onClick={this.removeSupply}
                    >X
                    </Badge>
                    &nbsp;&nbsp;
                    {supply.supplySf + ' - ' + supply.name}
                  </td>
                  <td style={{width: '5rem'}}>
                  <Input
                    style={{textAlign: 'right'}}
                    type='text'
                    name={i}
                    bsSize='sm'
                    placeholder={supply.unit}
                    onChange={this.handleQty}
                  ></Input>
                  </td>
                </tr>
                  )
                } else {
                  return null;
                }
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
