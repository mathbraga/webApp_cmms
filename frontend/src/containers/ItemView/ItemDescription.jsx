import React, { Component } from 'react';

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
            <Row>
              <Col md="3" style={{ textAlign: "end" }}><span className="desc-name">Edifício / Área</span></Col>
              <Col md="9" style={{ textAlign: "justify", paddingTop: "5px" }}><span>{assetsInfo.assetByAssetSf.name || "Não cadastrado"}</span></Col>
            </Row>
          </div>
          <div>
            <Row>
              <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Código</span></Col>
              <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{assetsInfo.assetByAssetSf.assetSf || "Não cadastrado"}</span></Col>
            </Row>
          </div>
          <div>
            <Row>
              <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Departamento(s)</span></Col>
              <Col md="9" style={{ display: "flex", alignItems: "center" }}>
                <span>{/*departments.map(item => (item.node.departmentByDepartmentId.departmentId)).join(' / ')*/ false || "Não cadastrado"}</span>
              </Col>
            </Row>
          </div>
          <div>
            <Row>
              <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Área</span></Col>
              <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{(assetsInfo.assetByAssetSf.area && assetsInfo.assetByAssetSf.area != 0) ? (assetsInfo.assetByAssetSf.area + " m²") : "Não cadastrado"}</span></Col>
            </Row>
          </div>
        </Col>
      </Row>
    );
  }
}

export default ItemDescription;