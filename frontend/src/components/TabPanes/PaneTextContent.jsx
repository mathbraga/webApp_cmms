import React, { Component } from 'react';
import TextField from './TextField';
import { Row, Col } from 'reactstrap';

export default class PaneTextContent extends Component {
  render() {
    const { numColumns, itemsMatrix } = this.props;
    return (
      <div className="asset-info-container">
        {itemsMatrix && (
          <div className="asset-info-content">
            {
              itemsMatrix.map((line, index) => (
                <Row
                  key={index}
                >
                  {
                    line && line.map((item) => (
                      <Col md={(12 / numColumns * item.span).toString()} style={item.style} key={item.id}>
                        {item.elementGenerator ?
                          item.elementGenerator() :
                          <TextField
                            title={item.title}
                            description={item.description}
                          />
                        }
                      </Col>
                    ))
                  }
                </Row>
              ))
            }
          </div>
        )}
      </div>
    );
  }
}