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
        <Row>
          <Col>
            <Autocomplete
              id="asset"
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