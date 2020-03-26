import React, { Component } from 'react';
import Dropzone from 'react-dropzone';

class DropArea extends Component {

  render() {

    const { handleDropFiles, handleRemoveFiles, files } = this.props;

    return (
      <React.Fragment>
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
          onDrop={selectedFiles => handleDropFiles(selectedFiles)}
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
      </React.Fragment>
    );
  }
}

export default DropArea;
