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

const thumbsContainer = {
  display: 'flex',
  flexDirection: 'row',
  flexWrap: 'wrap',
  marginTop: 16
};

const thumb = {
  display: 'inline-flex',
  borderRadius: 2,
  border: '1px solid #eaeaea',
  marginBottom: 8,
  marginRight: 8,
  width: 100,
  height: 100,
  padding: 4,
  boxSizing: 'border-box'
};

const thumbInner = {
  display: 'flex',
  minWidth: 0,
  overflow: 'hidden'
};

const img = {
  display: 'block',
  width: 'auto',
  height: '100%'
};

class DropArea extends Component {

  render() {

    const { handleDropFiles, handleRemoveFiles, files } = this.props;

    const filesListItems = files.map(file => (
      <li key={file.filename}>
        {file.name} - {file.size} bytes
      </li>
    ));

    const thumbs = files.map(file => (
      <div style={thumb} key={file.filename}>
        <div style={thumbInner}>
          <img
            src={file.preview}
            style={img}
          />
        </div>
      </div>
    ));

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
          onFileDialogCancel={handleRemoveFiles}
          preventDropOnDocument={true}
        >
          {({
            getRootProps,
            getInputProps,
            isDragAccept,
            isDragActive,
            isDragReject
          }) => {

            const style = {
              ...baseStyle,
              ...(isDragActive ? activeStyle : {}),
              ...(isDragAccept ? acceptStyle : {}),
              ...(isDragReject ? rejectStyle : {})
            };

            return (
              <section>
                <div {...getRootProps({ style })}>
                  <input {...getInputProps()} />
                  <p>Arraste e solte os arquivos nesta área ou clique para selecionar</p>
                </div>

                {/* <aside>
                  <p>{filesListItems.length > 0 ? "Arquivos selecionados:" : "Nenhum arquivo selecionado"}</p>
                  <ul>{filesListItems}</ul>
                </aside> */}

                <aside style={thumbsContainer}>
                  {thumbs}
                </aside>
              </section>
            )}}
        </Dropzone>
      </React.Fragment>
    );
  }
}

export default DropArea;
