import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { qQuery, qConfig } from "./graphql";
import getDownloadPath from '../../utils/getDownloadPath';

class OrderOne extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const { error, loading, one, files } = this.props;

    if(error) return <p>{JSON.stringify(error)}</p>;

    if(loading) return <h1>Carregando...</h1>;
    
    return (
      <React.Fragment>
        <p>{JSON.stringify(one)}</p>
        <table>
          <thead>
            <tr>
              <th>Filename</th>
              <th>Size</th>
              <th>PersonId</th>
              <th>CreatedAt</th>
            </tr>
          </thead>
          <tbody>
            {files.map(file => (
              <tr key={file.uuid} >
                <td>
                  <a
                    download
                    href={getDownloadPath(file.uuid + '/' + file.filename)}
                  >{file.filename}
                  </a>
                </td>
                <td>{file.size}</td>
                <td>{file.personId}</td>
                <td>{file.createdAt}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </React.Fragment>
    );
  }
}

export default graphql(qQuery, qConfig)(OrderOne);
