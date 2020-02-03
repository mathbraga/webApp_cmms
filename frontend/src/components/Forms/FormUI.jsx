import React, { Component } from 'react';
import AssetCard from '../Cards/AssetCard';
import InputField from '../Forms/InputField';
import NumberFormat from 'react-number-format';
import TextField from '@material-ui/core/TextField';
import { makeStyles } from '@material-ui/core/styles';
import { TextareaAutosize, MenuItem } from '@material-ui/core';
import CssBaseline from '@material-ui/core/CssBaseline';
import './Form.css';
import {
  Form,
  Row,
  Col,
  FormGroup,
  Label,
  Input
} from 'reactstrap';

import { data } from './utils/testData';

class FormUI extends Component {
  render() {
    const {
      title,
      subtitle,
      buttonName
    } = this.props;
    const { categoryOptions, contractOptions, priorityOptions, statusOptions } = data.allTaskFormData.nodes[0]
    console.log("Priority: ", priorityOptions);
    return (
      <>
        <CssBaseline>
          <AssetCard
            sectionName={title || 'Cadastro de Item'}
            sectionDescription={subtitle || 'Formulário para cadastro de novos itens'}
            handleCardButton={() => { console.log('OK!') }}
            buttonName={buttonName || 'Ativos'}
          >
            <div className="input-container">
              <h1 className="input-container-title">Descrição Geral</h1>
              <Row>
                <Col md={8}>
                  <TextField
                    id="outlined-full-width"
                    className="text-input"
                    fullWidth
                    label="Título"
                    placeholder="Instalação de um novo ponto de energia elétrica"
                    margin="normal"
                    InputLabelProps={{
                      shrink: true,
                    }}
                    variant="outlined"
                  />
                </Col>
                <Col md={4}>
                  <TextField
                    id="outlined-full-width"
                    className="text-input"
                    select
                    fullWidth
                    label="Prioridade"
                    placeholder="Instalação de um novo ponto de energia elétrica"
                    margin="normal"
                    InputLabelProps={{
                      shrink: true,
                    }}
                    variant="outlined">
                    {
                      priorityOptions.map(option => (
                        <MenuItem>
                          {option.taskPriorityText}
                        </MenuItem>
                      ))
                    }
                  </TextField>
                </Col>
              </Row>
              <Row style={{ marginTop: "0px" }}>
                <Col md={8}>
                  <TextField
                    id="outlined-full-width"
                    className="text-input"
                    fullWidth
                    label="Local"
                    placeholder="Auditório do Anexo II"
                    margin="normal"
                    InputLabelProps={{
                      shrink: true,
                    }}
                    variant="outlined"
                  />
                </Col>
                <Col md={4}>
                  <TextField
                    id="outlined-full-width"
                    className="text-input"
                    select
                    fullWidth
                    label="Categoria"
                    placeholder="Auditório do Anexo II"
                    margin="normal"
                    InputLabelProps={{
                      shrink: true,
                    }}
                    variant="outlined"
                  />
                </Col>
              </Row>
              <Row style={{ marginTop: "20px" }}>
                <Col>
                  <TextField
                    id="outlined-multiline-static"
                    className="text-input"
                    label="Descrição"
                    placeholder="Instalação de um novo ponto de energia elétrica para alimentar um computador."
                    fullWidth
                    multiline
                    rows="6"
                    rowsMax="20"
                    variant="outlined"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                </Col>
              </Row>
            </div>
            <div className="input-container" style={{ marginTop: "15px" }}>
              <h1 className="input-container-title">Execução</h1>
              <Row>
                <Col md={4}>
                  <TextField
                    id="outlined-full-width"
                    className="text-input"
                    fullWidth
                    label="Início"
                    placeholder="01/01/2020"
                    margin="normal"
                    InputLabelProps={{
                      shrink: true,
                    }}
                    variant="outlined"
                  />
                </Col>
                <Col md={4}>
                  <TextField
                    id="outlined-full-width"
                    className="text-input"
                    fullWidth
                    label="Data Limite"
                    placeholder="01/02/2020"
                    margin="normal"
                    InputLabelProps={{
                      shrink: true,
                    }}
                    variant="outlined"
                  />
                </Col>
                <Col md={4}>
                  <TextField
                    id="outlined-full-width"
                    className="text-input"
                    select
                    fullWidth
                    label="Status"
                    placeholder="Instalação de um novo ponto de energia elétrica"
                    margin="normal"
                    InputLabelProps={{
                      shrink: true,
                    }}
                    variant="outlined"
                  />
                </Col>
              </Row>
              <Row style={{ marginTop: "20px" }}>
                <Col md={8}>
                  <TextField
                    id="outlined-multiline-static"
                    className="text-input"
                    select
                    label="Projeto Pai"
                    fullWidth
                    rows="6"
                    rowsMax="20"
                    variant="outlined"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                </Col>
                <Col md={4}>
                  <TextField
                    id="outlined-multiline-static"
                    className="text-input"
                    label="Projeto"
                    fullWidth
                    rows="6"
                    rowsMax="20"
                    variant="outlined"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                </Col>
              </Row>
              <Row style={{ marginTop: "20px" }}>
                <Col>
                  <TextField
                    id="outlined-multiline-static"
                    className="text-input"
                    select
                    label="Contrato"
                    fullWidth
                    rows="6"
                    rowsMax="20"
                    variant="outlined"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                </Col>
              </Row>
              <Row style={{ marginTop: "20px" }}>
                <Col>
                  <TextField
                    id="outlined-multiline-static"
                    className="text-input"
                    select
                    label="Atribuir Para"
                    placeholder="Rcs Tecnologia - Central"
                    fullWidth
                    rows="6"
                    rowsMax="20"
                    variant="outlined"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                </Col>
              </Row>
            </div>
            <div className="input-container" style={{ marginTop: "15px" }}>
              <h1 className="input-container-title">Ativos</h1>
              <Row>
                <Col>
                  <TextField
                    id="outlined-multiline-static"
                    className="text-input"
                    label="Equipamentos / Edifícios"
                    placeholder="Instalação de um novo ponto de energia elétrica para alimentar um computador."
                    fullWidth
                    multiline
                    rows="6"
                    rowsMax="20"
                    variant="outlined"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                </Col>
              </Row>
            </div>
          </AssetCard>
        </CssBaseline>
      </>
    );
  }
}

export default FormUI;