import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { query, config } from "./graphql";
import getDownloadPath from '../getDownloadPath';

class Order extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const { test, fileList, error, loading } = this.props;

    if(error) return <h1>{error}</h1>;
    if(loading) return <h1>Carregando...</h1>
    else{

      // console.log(data);

      return (
        <React.Fragment>
          <h1>Query ok</h1>
          <p>{JSON.stringify(test)}</p>
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
              {fileList.map(file => (
                <tr>
                  <td><a
                        download
                        href={getDownloadPath(file.filename)}
                        target="_blank"
                        rel="noopener noreferrer nofollow"
                      >{file.filename}
                    </a></td>
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
}

export default graphql(query, config)(Order);
