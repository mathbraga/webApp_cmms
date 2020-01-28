import React, { Component } from 'react';
import AssetCard from '../Cards/AssetCard';
import InputField from '../Forms/InputField';
import NumberFormat from 'react-number-format';
import './Form.css';
import {
  Form,
  Row,
  Col,
  FormGroup,
  Label,
  Input
} from 'reactstrap';

class FormUI extends Component {
  render() {
    const {
      title,
      subtitle,
      buttonName
    } = this.props;
    return (
      <AssetCard
        sectionName={title || 'Cadastro de Item'}
        sectionDescription={subtitle || 'Formulário para cadastro de novos itens'}
        handleCardButton={() => { console.log('OK!') }}
        buttonName={buttonName || 'Ativos'}
      >
        <div className="input-container">
          <Form style={{ margin: "20px" }}>
            <h1 className="input-container-title">Dados Gerais</h1>
            <Row form>
              <Col md={6}>
                <FormGroup>
                  <Label for="examplePassword">Telefone</Label>
                  <NumberFormat
                    value={12345678890}
                    displayType={"text"}
                    thousandSeparator={true}
                    prefix={'$  '}
                    renderText={value => (
                      <Input type="text" name="text" id="text" value={value} />
                    )}
                  />
                </FormGroup>
              </Col>
              <Col md={6}>
                <FormGroup>
                  <Label for="examplePassword">Password</Label>
                  <Input type="password" name="password" id="examplePassword" placeholder="password placeholder" />
                </FormGroup>
              </Col>
            </Row>
            <FormGroup>
              <Label for="exampleText">Descrição</Label>
              <Input type="textarea" name="text" id="exampleText" />
            </FormGroup>
          </Form>
          <Form style={{ margin: "20px" }}>
            <h1 className="input-container-title">Dados Gerais</h1>
            <Row form>
              <Col md={6}>
                <FormGroup>
                  <Label for="exampleEmail">Email</Label>
                  <Input type="email" name="email" id="exampleEmail" placeholder="with a placeholder" />
                </FormGroup>
              </Col>
              <Col md={6}>
                <FormGroup>
                  <Label for="examplePassword">Password</Label>
                  <Input type="password" name="password" id="examplePassword" placeholder="password placeholder" />
                </FormGroup>
              </Col>
            </Row>
            <FormGroup>
              <Label for="exampleText">Descrição</Label>
              <Input type="textarea" name="text" id="exampleText" />
            </FormGroup>
          </Form>
        </div>
        <div style={{ marginTop: "30px" }} className="input-container">
          <Form style={{ margin: "20px" }}>
            <h1 className="input-container-title">Dados Gerais</h1>
            <Row form>
              <Col md={6}>
                <FormGroup>
                  <Label for="exampleEmail">Email</Label>
                  <Input type="email" name="email" id="exampleEmail" placeholder="with a placeholder" />
                </FormGroup>
              </Col>
              <Col md={6}>
                <FormGroup>
                  <Label for="examplePassword">Password</Label>
                  <Input type="password" name="password" id="examplePassword" placeholder="password placeholder" />
                </FormGroup>
              </Col>
            </Row>
            <FormGroup>
              <Label for="exampleText">Descrição</Label>
              <Input type="textarea" name="text" id="exampleText" />
            </FormGroup>
          </Form>
        </div>
      </AssetCard>
    );
  }
}

export default FormUI;