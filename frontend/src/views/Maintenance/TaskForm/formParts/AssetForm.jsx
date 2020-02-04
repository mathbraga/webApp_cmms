import React, { Component } from 'react';
import {
  TextField
} from '@material-ui/core';
import Autocomplete from '@material-ui/lab/Autocomplete';
import {
  Row,
  Col,
} from 'reactstrap';

class AssetForm extends Component {
  render() {
    const { assetOptions, handleAssetChange } = this.props;
    return (
      <>
        <h1 className="input-container-title" style={{ marginBottom: "30px" }}>Cadastro de Ativos</h1>
        <Row>
          <Col>
            <Autocomplete
              id="combo-box-demo"
              multiple
              options={assetOptions}
              getOptionLabel={option => (`${option.assetSf}: ${option.name}`)}
              filterSelectedOptions
              margin="normal"
              onChange={handleAssetChange}
              value={this.props.assets}
              renderInput={params => (
                <TextField
                  {...params}
                  variant="outlined"
                  fullWidth
                  margin="normal"
                  className="text-input"
                  label="Equipamentos / Edifícios"
                  placeholder="O cadastro de ativo é obrigatório"
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

export default AssetForm;