import React, { Component } from 'react';
import AssetCard from '../../components/Cards/AssetCard';
import CssBaseline from '@material-ui/core/CssBaseline';
import { Button } from '@material-ui/core';
import { compose } from 'redux';
import './TaskForm.css';
import DescriptionForm from './formParts/DescriptionForm';
import ExecutionForm from './formParts/ExecutionForm';
import AssetForm from './formParts/AssetForm';
import Dropzone from 'react-dropzone';
import props from './props';
import { withProps, withGraphQL, withQuery, withForm, withMutation } from '../../hocs';
import paths from '../../paths';

class TaskForm extends Component {
  render() {
    const { history, handleFunctions, formState, mutate, files } = this.props;
    const data = this.props.data.formData.nodes[0];
    return (
      <CssBaseline>
        <AssetCard
          sectionName={'Cadastro de OS'}
          sectionDescription={'Formulário para cadastro de novas ordens de serviço'}
          handleCardButton={() => { history.push(paths.task.all) }}
          buttonName={'Ordens de Serviço'}
        >
          <div className="input-container">
            <form noValidate autoComplete="off">
              <DescriptionForm
                handleInputChange={handleFunctions.handleInputChange}
                priorityOptions={data.priorityOptions}
                categoryOptions={data.categoryOptions}
                {...formState}
              />
              <div style={{ marginTop: "60px" }} />
              <ExecutionForm
                handleInitialDateInputChange={handleFunctions.handleInitialDateInputChange}
                handleLimitDateInputChange={handleFunctions.handleLimitDateInputChange}
                handleInputChange={handleFunctions.handleInputChange}
                handleContractChange={handleFunctions.handleContractChange}
                handleTeamChange={handleFunctions.handleTeamChange}
                handleProjectChange={handleFunctions.handleProjectChange}
                statusOptions={data.statusOptions}
                projectOptions={data.projectOptions}
                teamOptions={data.teamOptions}
                contractOptions={data.contractOptions}
                {...formState}
              />
              <div style={{ marginTop: "60px" }} />
              <AssetForm
                assetOptions={data.assetOptions}
                handleAssetChange={handleFunctions.handleAssetChange}
                {...formState}
              />
              <div style={{ marginTop: "60px" }} />
                <h1 className="input-container-title" style={{ marginBottom: "30px" }}>Arquivos</h1>
                <Dropzone
                  // accept={}
                  // children={}
                  disabled={false}
                  // getFilesFromEvent={}
                  // maxSize={}
                  // minSize={}
                  multiple={true}
                  noClick={false}
                  noDrag={false}
                  noDragEventsBubbling={false}
                  onDragEnter={() => {}}
                  onDragLeave={() => {}}
                  onDragOver={() => {}}
                  onDrop={selectedFiles => handleFunctions.handleDropFiles(selectedFiles)}
                  // onDropAccepted={}
                  // onDropRejected={}
                  onFileDialogCancel={() => {}}
                  preventDropOnDocument={true}
                >
                  {({getRootProps, getInputProps}) => (
                    <section className="container">
                      <div {...getRootProps()}>
                        <input {...getInputProps()} />
                        <p>Arraste e solte os arquivos nesta área ou clique para selecionar</p>
                      </div>
                      <aside>
                        <h5>{files.length > 0 ? "Arquivos selecionados:" : "Nenhum arquivo selecionado"}</h5>
                        <ul>{files}</ul>
                      </aside>
                    </section>
                  )}
                </Dropzone>
              <div style={{ marginTop: "60px" }} />
              <div style={{ display: "flex", justifyContent: "flex-end" }}>
                <Button
                  variant="contained"
                  color="primary"
                  style={{ marginRight: "10px" }}
                  onClick={mutate}
                >
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
  withProps(props),
  withGraphQL,
  withQuery,
  withForm,
  withMutation
)(TaskForm);