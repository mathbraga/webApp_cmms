import React, { Component } from 'react';
import { DescriptionField } from './DescriptionField';
import { Row, Col } from './reacstrap';

const testObj = {
  title: 'Dados Gerais',
  numColumns: 2,
  data: [
    [{ id: 'facility', title: 'Edifício', description: 'SQS 309', span: 1 }, { id: 'facility', title: 'Edifício', description: 'SQS 309', line: 1, span: 1 },],
    [{ id: 'facility', title: 'Edifício', description: 'SQS 309', span: 1 }],
    [{ id: 'facility', title: 'Edifício', description: 'SQS 309', span: 2 }]
  ]
}

class DescriptionTable extends Component {
  render() {
    const { title, data } = this.props;
    const { numColumns } = data;

    return (
      <div className="asset-info-container">
        <h1 className="asset-info-title">{title}</h1>
        <div className="asset-info-content">
          {
            data.map((line) => (
              <Row>
                {
                  line.map((item) => (
                    <Col md={(12 / numColumns * item.span).toString()}>
                      <DescriptionField
                        title={data.title}
                        description={data.description}
                      />
                    </Col>
                  ))
                }
              </Row>
            ))
          }
        </div>
      </div>
    );
  }
}

export default DescriptionTable;