import React, { Component } from 'react';
import './ItemView.css';

const dataTest = {
  id: 'facility1',
  image: 'image',
  status: 'status',
  descriptionItems: [
    {title: 'item1', description: 'description1', boldTitle: true}
  ]
};

export default class ItemDescription extends Component {
  render() {
    const { image, status, descriptionItems } = this.props;
    return (
      <Row>
        <Col md="2" style={{ textAlign: "left" }}>
          <div className="desc-box">
            <div className="desc-img-container">
              <img className="desc-image" src={image} alt="Ar-condicionado" />
            </div>
            <div className="desc-status">
              <Badge className="mr-1 desc-badge" color="success">{status}</Badge>
            </div>
          </div>
        </Col>
        <Col className="flex-column" md="10">
          {descriptionItems.map((item, index) => {
            if (index === 0 ) {
              return (
                <div style={{ flexGrow: "1" }}>
                  <Row>
                    <Col md="3" style={{ textAlign: "end" }}><span className="desc-name">{item.title}</span></Col>
                    <Col md="9" style={{ textAlign: "justify", paddingTop: "5px" }}><span>{item.description || "Não cadastrado"}</span></Col>
                  </Row>
                </div>
              );
            }
            
            return (
              <Row>
                <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">{item.title}</span></Col>
                <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{item.description || "Não cadastrado"}</span></Col>
              </Row>
            );
          })}
        </Col>
      </Row>
    );
  }
}