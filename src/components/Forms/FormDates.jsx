import React, { Component } from "react";
import {
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  Label,
  Input,
  FormGroup,
  Button
} from "reactstrap";

class FormDates extends Component {
  state = {};
  render() {
    return (
      <Card>
        <CardHeader>
          <strong>Período do Consumo</strong>
        </CardHeader>
        <CardBody>
          <FormGroup row>
            <Label htmlFor="initialDate" sm={"auto"}>
              <strong>Início:</strong>
            </Label>
            <Col sm={2}>
              <Input
                type="text"
                id="initialDate"
                placeholder="mm/yyyy"
                required
              />
            </Col>
            <Label htmlFor="finalDate" sm={"auto"}>
              <strong>Fim:</strong>
            </Label>
            <Col sm={2}>
              <Input
                type="text"
                id="finalDate"
                placeholder="mm/yyyy"
                required
              />
            </Col>
            <Label htmlFor="finalDate" sm={{ size: "auto", offset: 0 }}>
              <strong>Unidade Consumidora:</strong>
            </Label>
            <Col sm={3}>
              <Input type="select" name="consumerUnit" id="exampleSelect">
                <option value="1">620.190-50 - Unidade de Apoio I</option>
                <option value="2">620.190-51</option>
                <option value="3">620.190-52</option>
                <option value="4">620.190-53</option>
                <option value="5">Todos</option>
              </Input>
            </Col>
            <Col>
              <Button type="submit" size="md" color="primary">
                Pesquisar
              </Button>
            </Col>
          </FormGroup>
        </CardBody>
      </Card>
    );
  }
}

export default FormDates;
