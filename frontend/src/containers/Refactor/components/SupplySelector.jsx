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
    }
  }

  render() {

    const { contractId, options, selected, addSupply, removeSupply, handleQty } = this.props;
    let idx = -1;

    return (
      <Card>
        {/* <CardHeader>{"Materiais e Serviços"}</CardHeader> */}

        <CardBody>
        <p><strong>Materiais e Serviços</strong></p>
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
                      onClick={addSupply}
                    >+</Badge>
                    &nbsp;&nbsp;
                    {supply.supplySf + ' - ' + supply.name}
                  </td>
                </tr>
              ))}
            </tbody>
          </Table>
          <hr/>

          {selected.length === 0 ? (
            <p style={{textAlign: 'right'}}><em>Nenhum item selecionado</em></p>
          ) : (
            <React.Fragment>
              <p style={{textAlign: 'right'}}><em>Defina as quantidades</em></p>
              <Table hover borderless size='sm'>
                <tbody>
                  {selected.map((supplyId, i) => {
                    const sup = options.find(supply => supplyId === supply.supplyId)
                      idx++;
                      return (
                        <tr key={sup.supplyId}>
                      <td>
                        <Badge
                          name={sup.supplyId}
                          href={"#"}
                          color='danger'
                          onClick={removeSupply}
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
                        onBlur={handleQty}
                      ></Input>
                      </td>
                    </tr>
                      )
                  })}
                </tbody>
              </Table>
            </React.Fragment>
          )}
          
          
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
    variables: {contractId: Number(props.contractId)},
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
