import React, { Component } from 'react';
import {
  TextField,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Button
} from '@material-ui/core';
import Autocomplete from '@material-ui/lab/Autocomplete';
import {
  Row,
  Col,
} from 'reactstrap';
import ListboxComponent from './ListboxComponent';

const mapIcon = require("../../../assets/icons/delete.png");

class ParentForm extends Component {

  render() {
    const { handleParentChange, handleContextChange, addNewParent, removeParent } = this.props;
    const { topOptions, parentOptions } = this.props.formData;

    return (
      <>
        <h1 className="input-container-title" style={{ marginBottom: "30px" }}>Relação entre Ativos</h1>
        <Row>
          <Col md={8}>
            <Autocomplete
              id="combo-box-demo"
              options={parentOptions}
              getOptionLabel={option => (`${option.assetSf}: ${option.name}`)}
              filterSelectedOptions
              onChange={handleParentChange}
              value={this.props.parent}
              ListboxComponent={ListboxComponent}
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
              options={topOptions}
              getOptionLabel={option => option.name}
              filterSelectedOptions
              onChange={handleContextChange}
              value={this.props.context}
              ListboxComponent={ListboxComponent}
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
        <div style={{ marginTop: "10px" }} />
        <div style={{ display: "flex", justifyContent: "flex-end" }}>
          <Button
            variant="contained"
            color="primary"
            style={{ background: "green" }}
            onClick={addNewParent}
          >
            Adicionar
          </Button>
        </div>
        <div className="table-container-form" >
          <TableContainer component={Paper}>
            <Table aria-label="simple table">
              <TableHead>
                <TableRow>
                  <TableCell align="center" style={{ width: "50px" }}></TableCell>
                  <TableCell align="left" style={{ width: "400px" }}>Ativo Pai</TableCell>
                  <TableCell align="center" style={{ width: "200px" }}>Contexto</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {(this.props.parents.length === 0
                  ?
                  <TableRow>
                    <TableCell></TableCell>
                    <TableCell>Não há itens cadastrados.</TableCell>
                    <TableCell></TableCell>
                  </TableRow>
                  : this.props.parents.map((row) => (
                    <TableRow>
                      <TableCell align="center" component="th" scope="row">
                        <img
                          onClick={() => removeParent(row.id)}
                          src={mapIcon}
                          alt="Delete"
                          style={{ width: "25px", height: "25px", cursor: "pointer" }}
                        />
                      </TableCell>
                      <TableCell align="left" component="th" scope="row">
                        {`${row.parent.assetSf}: ${row.parent.name}`}
                      </TableCell>
                      <TableCell align="center" component="th" scope="row">
                        {row.context.name}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </div>
      </>
    );
  }
}

export default ParentForm;