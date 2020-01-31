import React, { Component } from 'react';
import {
  TextField
} from '@material-ui/core';
import Autocomplete from '@material-ui/lab/Autocomplete';
import {
  Row,
  Col,
} from 'reactstrap';

class ParentForm extends Component {
  render() {
    const { handleParentChange } = this.props;
    const { categoryOptions } = this.props.data;
    return (
      <>
        <h1 className="input-container-title" style={{ marginBottom: "30px" }}>Relação de Ativos</h1>
        <Row>
          <Col md={8}>
            <Autocomplete
              id="combo-box-demo"
              options={categoryOptions}
              getOptionLabel={option => option.taskCategoryText}
              filterSelectedOptions
              onChange={handleParentChange}
              value={this.props.parents}
              renderInput={params => (
                <TextField
                  {...params}
                  variant="outlined"
                  fullWidth
                  className="text-input"
                  label="Ativo Pai"
                  placeholder="Preenchimento Obrigatório"
                  InputLabelProps={{
                    shrink: true,
                  }}
                />
              )}
            />
          </Col>
          <Col md={4}>
            <Autocomplete
              id="combo-box-demo"
              options={categoryOptions}
              getOptionLabel={option => option.taskCategoryText}
              filterSelectedOptions
              onChange={handleParentChange}
              value={this.props.parents}
              renderInput={params => (
                <TextField
                  {...params}
                  variant="outlined"
                  fullWidth
                  className="text-input"
                  label="Contexto"
                  placeholder=""
                  InputLabelProps={{
                    shrink: true,
                  }}
                />
              )}
            />
          </Col>
        </Row>
      </>
    );
  }
}

export default ParentForm;