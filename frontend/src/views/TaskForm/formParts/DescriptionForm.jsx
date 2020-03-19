import React, { Component } from 'react';
import TextField from '@material-ui/core/TextField';
import { MenuItem } from '@material-ui/core';
import {
  Row,
  Col,
} from 'reactstrap';

class DescriptionForm extends Component {
  render() {
    const {
      handleInputChange,
      priorityOptions,
      categoryOptions
    } = this.props;
    return (
      <>
        <h1 className="input-container-title">Descrição do Serviço</h1>
        <Row>
          <Col md={8}>
            <TextField
              value={this.props.title}
              className="text-input"
              name="title"
              fullWidth
              label="Título"
              placeholder="Instalação de um novo ponto de energia elétrica"
              onChange={handleInputChange}
              margin="normal"
              InputLabelProps={{
                shrink: true,
              }}
              variant="outlined"
            />
          </Col>
          <Col md={4}>
            <TextField
              value={this.props.priority}
              className="text-input"
              name="priority"
              select
              fullWidth
              label="Prioridade"
              margin="normal"
              onChange={handleInputChange}
              InputLabelProps={{
                shrink: true,
              }}
              variant="outlined">
              {
                priorityOptions.map(option => (
                  <MenuItem key={option.taskPriorityId} value={option.taskPriorityId}>
                    {option.taskPriorityText}
                  </MenuItem>
                ))
              }
            </TextField>
          </Col>
        </Row>
        <Row>
          <Col md={8}>
            <TextField
              value={this.props.place}
              className="text-input"
              name="place"
              fullWidth
              label="Local"
              placeholder="Auditório do Interlegis"
              onChange={handleInputChange}
              margin="normal"
              InputLabelProps={{
                shrink: true,
              }}
              variant="outlined"
            />
          </Col>
          <Col md={4}>
            <TextField
              value={this.props.category}
              className="text-input"
              name="category"
              select
              fullWidth
              label="Categoria"
              margin="normal"
              onChange={handleInputChange}
              InputLabelProps={{
                shrink: true,
              }}
              variant="outlined">
              {categoryOptions.map(option => (
                <MenuItem key={option.taskCategoryId} value={option.taskCategoryId}>
                  {option.taskCategoryText}
                </MenuItem>
              ))}
            </TextField>
          </Col>
        </Row>
        <Row style={{ marginTop: "15px" }}>
          <Col>
            <TextField
              id="description"
              value={this.props.description}
              className="text-input"
              name="description"
              label="Descrição"
              placeholder="Instalação de um novo ponto de energia elétrica para alimentar um computador."
              fullWidth
              multiline
              onChange={handleInputChange}
              rows="6"
              rowsMax="20"
              variant="outlined"
              InputLabelProps={{
                shrink: true,
              }}
            />
          </Col>
        </Row>
      </>
    );
  }
}

export default DescriptionForm;