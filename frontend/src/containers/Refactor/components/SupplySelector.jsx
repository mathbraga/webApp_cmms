import React, { Component } from "react";
import { 
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
    this.handleSelect = this.handleSelect.bind(this);
  }

  handleSelect(event){
    this.setState({ selected: getSupplyList(event.target.options, this.props.options)})
  }

  render() {

    const { contractId, options, selected, onChange } = this.props;

    return (
      <Card>
              <CardHeader>
                <strong>{"Materiais e Serviços"}</strong>
              </CardHeader>
              <CardBody>
                <Form>
                    <FormGroup row>
                      <Col>Materiais e Serviços</Col>
                    <Col xs="12">
                      <Input
                        style={{height:'15rem'}}
                        type="select"
                        id="supplies"
                        name="supplies"
                        onChange={this.handleSelect}
                        multiple={true}
                      >
                        {options ? (
                        <React.Fragment>
                          {options.map(supply => 
                          <option
                            key={supply.supplyId}
                            value={supply.supplyId}
                          >{supply.supplySf + ' - ' + supply.name}</option>
                        )}
                        </React.Fragment>
                      ) : (
                        <option disabled>Selecione um contrato antes de definir os materiais e serviços</option>
                      )}
                      </Input>
                    </Col>
                  </FormGroup>




                  {this.state.selected ? (
                  <React.Fragment>
                    <Row className="mb-4">
                      <Col xs="10"><strong>Selecionados</strong></Col>
                      <Col xs="2"><strong>Qtd.</strong></Col>
                    </Row>
                    {this.state.selected.map((item, i) => (
                      <FormGroup row>
                        <Col xs="10">
                          <Label>{item.supplySf + ' - ' + item.name}</Label>
                        </Col>
                        <Col xs="2">
                          <Input
                            type="text"
                            id={i}
                            name={'supply-qty'}
                            onChange={onChange}
                          >
                          </Input>
                        </Col>
                      </FormGroup>
                    ))}
                  </React.Fragment>
                  ) : (
                    <p>Nenhum item selecionado.</p>
                  )}




                </Form>
              </CardBody>
            </Card>
    );
  }
}



export const QQuery = gql`
  query ($contractId: Int) {
    supplies: allSuppliesLists(condition: {contractId: $contractId}) {
      nodes {
        supplyId
        supplySf
        name
      }
    }
  }
`;

export const QConfig = {
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
  skip: props => !props.contractId,
  // name: ,
  // withRef: ,
  // alias: ,
};


export default graphql(QQuery, QConfig)(SupplySelector);
