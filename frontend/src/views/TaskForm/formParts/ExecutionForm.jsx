import React, { Component } from 'react';
import {
  MenuItem,
  TextField,
} from '@material-ui/core';
import DateFnsUtils from '@date-io/date-fns';
import Autocomplete from '@material-ui/lab/Autocomplete';
import {
  MuiPickersUtilsProvider,
  KeyboardDatePicker,
} from '@material-ui/pickers';
import {
  Row,
  Col,
} from 'reactstrap';

class ExecutionForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hasProject: false,
    }
  }

  onChangeTest(e, newValue) {
    console.log("Change: ", newValue);
  }

  render() {
    const {
      handleInitialDateInputChange,
      handleLimitDateInputChange,
      handleInputChange,
      handleContractChange,
      handleTeamChange,
      handleProjectChange,
      handleAssetChange,
      projectOptions,
      statusOptions,
      teamOptions,
      contractOptions
    } = this.props;
    return (
      <>
        <h1 className="input-container-title" style={{ marginBottom: "15px" }}>Execução</h1>
        <MuiPickersUtilsProvider utils={DateFnsUtils}>
          <Row style={{ marginLeft: "3px" }}>
            <Col md="4">
              <KeyboardDatePicker
                disableToolbar
                variant="dialog"
                format="dd/MM/yyyy"
                placeholder="DD/MM/AAAA"
                margin="normal"
                id="date-picker-inline"
                onChange={handleInitialDateInputChange}
                value={this.props.initialDate}
                label="Data Inicial"
                InputLabelProps={{
                  shrink: true,
                }}
                KeyboardButtonProps={{
                  'aria-label': 'change date',
                }}
              />
            </Col>
            <Col md="4">
              <KeyboardDatePicker
                disableToolbar
                variant="dialog"
                format="dd/MM/yyyy"
                placeholder="DD/MM/AAAA"
                margin="normal"
                id="date-picker-inline"
                onChange={handleLimitDateInputChange}
                value={this.props.limitDate}
                label="Data Limite"
                InputLabelProps={{
                  shrink: true,
                }}
                KeyboardButtonProps={{
                  'aria-label': 'change date',
                }}
              />
            </Col>
            <Col md="4">
              <TextField
                id="outlined-full-width"
                value={this.props.status}
                className="text-input"
                name="status"
                select
                fullWidth
                label="Status"
                margin="normal"
                onChange={handleInputChange}
                InputLabelProps={{
                  shrink: true,
                }}
                variant="outlined">
                {
                  statusOptions.map(option => (
                    <MenuItem key={option.taskStatusId} value={option.taskStatusId}>
                      {option.taskStatusText}
                    </MenuItem>
                  ))
                }
              </TextField>
            </Col>
          </Row>
          <Row style={{ marginTop: "15px" }}>
            <Col md="6">
              <Autocomplete
                id="combo-box-demo"
                name="contract"
                options={contractOptions}
                value={this.props.contract}
                getOptionLabel={option => (`${option.contractSf} - ${option.title}`)}
                onChange={handleContractChange}
                renderInput={params => (
                  <TextField
                    {...params}
                    variant="outlined"
                    fullWidth
                    name="contract"
                    className="text-input"
                    label="Contratos"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                )}
              />
            </Col>
            <Col md="6">
              <Autocomplete
                id="combo-box-demo"
                name="team"
                options={teamOptions}
                getOptionLabel={option => option.name}
                value={this.props.team}
                onChange={handleTeamChange}
                renderInput={params => (
                  <TextField
                    {...params}
                    variant="outlined"
                    fullWidth
                    className="text-input"
                    label="Atribuir Para"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                )}
              />
            </Col>
          </Row>
          <Row style={{ marginTop: "20px" }}>
            <Col>
              <Autocomplete
                id="combo-box-demo"
                options={projectOptions}
                getOptionLabel={option => option.name}
                value={this.props.project}
                onChange={handleProjectChange}
                style={{
                  "-webkit-font-smoothing": "antialiased",
                }}
                renderInput={params => (
                  <TextField
                    {...params}
                    variant="outlined"
                    fullWidth
                    className="text-input"
                    placeholder="Ordem de Serviço SEM projeto (padrão)"
                    label="Projeto Pai"
                    InputLabelProps={{
                      shrink: true,
                    }}
                  />
                )}
              />
            </Col>
          </Row>
        </MuiPickersUtilsProvider>
      </>
    );
  }
}

export default ExecutionForm;