import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';
import TextField from '@material-ui/core/TextField';
import withDataFetching from '../../../components/DataFetch';
import { makeStyles } from '@material-ui/core/styles';
import { TextareaAutosize, MenuItem } from '@material-ui/core';
import CssBaseline from '@material-ui/core/CssBaseline';
import { Button } from '@material-ui/core';
import { withRouter } from 'react-router-dom';
import { compose } from 'redux';
import './TaskForm.css';
import {
  Form,
  Row,
  Col,
  FormGroup,
  Label,
  Input
} from 'reactstrap';

import { fetchGQL, fetchVariables } from './utils/dataFetchParameters';
import DescriptionForm from './formParts/DescriptionForm';
import ExecutionForm from './formParts/ExecutionForm';
import AssetForm from './formParts/AssetForm';

class TaskForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      title: "",
      place: "",
      description: "",
      priority: 2,
      category: null,
      initialDate: null,
      limitDate: null,
      status: 3,
    }

    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleInitialDateInputChange = this.handleInitialDateInputChange.bind(this);
  }

  handleInputChange(event) {
    const { value, name } = event.target;
    this.setState({
      [name]: value
    });
  }

  handleInitialDateInputChange(date) {
    this.setState({
      initialDate: date,
    });
  }

  render() {
    const { history } = this.props;
    const data = this.props.data.allTaskFormData.nodes[0];
    return (
      <CssBaseline>
        <AssetCard
          sectionName={'Cadastro de OS'}
          sectionDescription={'Formulário para cadastro de novas ordens de serviço'}
          handleCardButton={() => { history.push("/manutencao/os") }}
          buttonName={'Ordens de Serviço'}
        >
          <div className="input-container">
            <form noValidate autoComplete="off">
              <DescriptionForm
                handleInputChange={this.handleInputChange}
                priorityOptions={data.priorityOptions}
                categoryOptions={data.categoryOptions}
                {...this.state}
              />
              <div style={{ marginTop: "60px" }} />
              <ExecutionForm
                handleInitialDateInputChange={this.handleInitialDateInputChange}
                handleInputChange={this.handleInputChange}
                statusOptions={data.statusOptions}
                projectOptions={data.projectOptions}
                teamOptions={data.teamOptions}
                contractOptions={data.contractOptions}
                {...this.state}
              />
              <div style={{ marginTop: "60px" }} />
              <AssetForm
                assetOptions={data.teamOptions}
                {...this.state}
              />
              <div style={{ marginTop: "60px" }} />
              <div style={{ display: "flex", justifyContent: "flex-end" }}>
                <Button variant="contained" color="primary" style={{ marginRight: "10px" }}>
                  Cadastrar
                </Button>
                <Button variant="contained" style={{ marginRight: "10px" }}>
                  Limpar
                </Button>
                <Button variant="contained" color="secondary">
                  Cancelar
                </Button>
              </div>
            </form>
          </div>
        </AssetCard>
      </CssBaseline>
    );
  }
}

export default compose(
  withRouter,
  withDataFetching(fetchGQL, fetchVariables)
)(TaskForm);