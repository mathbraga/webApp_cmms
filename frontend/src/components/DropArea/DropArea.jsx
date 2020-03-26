import React, { Component, useMemo } from 'react';
import Dropzone from 'react-dropzone';

const baseStyle = {
  flex: 1,
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  padding: '20px',
  borderWidth: 2,
  borderRadius: 2,
  borderColor: '#eeeeee',
  borderStyle: 'dashed',
  backgroundColor: '#fafafa',
  color: '#bdbdbd',
  outline: 'none',
  transition: 'border .24s ease-in-out'
};

const activeStyle = {
  borderColor: '#2196f3'
};

const acceptStyle = {
  borderColor: '#00e676'
};

const rejectStyle = {
  borderColor: '#ff1744'
};


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
          {({
            getRootProps,
            getInputProps,
            isDragAccept,
            isDragActive,
            isDragReject
          }) => {

            const style = useMemo(() => ({
              ...baseStyle,
              ...(isDragActive ? activeStyle : {}),
              ...(isDragAccept ? acceptStyle : {}),
              ...(isDragReject ? rejectStyle : {})
            }), [
              isDragActive,
              isDragReject
            ]);

            return (
              <section>
                <div {...getRootProps({ style })}>
                  <input {...getInputProps()} />
                  <p>Arraste e solte os arquivos nesta área ou clique para selecionar</p>
                </div>
                <aside>
                  <h5>{files.length > 0 ? "Arquivos selecionados:" : "Nenhum arquivo selecionado"}</h5>
                  <ul>{files}</ul>
                </aside>
              </section>
            )}}
        </Dropzone>
      </React.Fragment>
    );
  }
}

export default DropArea;
