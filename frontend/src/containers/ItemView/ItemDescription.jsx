import React, { Component } from 'react';
import HorizontalField from '../../components/Description/HorizontalField';

class ItemDescription extends Component {
  render() {
    return (
      <Row>
        <Col md="2" style={{ textAlign: "left" }}>
          <div className="desc-box">
            <div className="desc-img-container">
              <img className="desc-image" src={descriptionImage} alt="Ar-condicionado" />
            </div>
            <div className="desc-status">
              <Badge className="mr-1 desc-badge" color="success" >Trânsito Livre</Badge>
            </div>
          </div>
        </Col>
        <Col className="flex-column" md="10">
          <div style={{ flexGrow: "1" }}>
            <HorizontalField
              boldTitle={true}
              title={"Edifício / Área"}
              description={}
            />
          </div>
          <div>
            <HorizontalField
              title={"Código"}
              description={}
            />
          </div>
          <div>
            <HorizontalField
              title={"Departamento(s)"}
              description={}
            />
          </div>
          <div>
            <HorizontalField
              title={"Área"}
              description={}
            />
          </div>
        </Col>
      </Row>
    );
  }
}

export default ItemDescription;