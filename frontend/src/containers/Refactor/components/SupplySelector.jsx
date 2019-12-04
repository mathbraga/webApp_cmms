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

class SupplySelector extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { queryCondition, options, selected, addItem, removeItem, handleQty } = this.props;
    let idx = -1;

    return (
      <Card>
        <CardBody>
          <p><strong>Materiais e Serviços</strong></p>
          <Table hover borderless size='sm' style={{display: 'block', height: '10rem', overflow: 'scroll'}}>
            <tbody>
              {options.map((option, i) => (
                <tr key={i}>
                  <td>
                    <Badge
                      size='sm'
                      name={option.supplyId}
                      href={"#"}
                      color='success'
                      onClick={addItem}
                    >+</Badge>
                    &nbsp;&nbsp;
                    {option.supplySf + ' - ' + option.name}
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
                  {selected.map((selectedId, i) => {
                    const selectedItem = options.find(option => selectedId === option.supplyId)
                      idx++;
                      return (
                        <tr key={selectedItem.supplyId}>
                      <td>
                        <Badge
                          name={selectedItem.supplyId}
                          href={"#"}
                          color='danger'
                          onClick={removeItem}
                        >X
                        </Badge>
                        &nbsp;&nbsp;
                        {selectedItem.supplySf + ' - ' + selectedItem.name}
                      </td>
                      <td style={{width: '5rem'}}>
                      <Input
                        style={{textAlign: 'right'}}
                        type='text'
                        name={idx}
                        bsSize='sm'
                        placeholder={selectedItem.unit}
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
    variables: {contractId: Number(props.queryCondition)},
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
