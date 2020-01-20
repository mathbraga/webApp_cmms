import React, { Component } from 'react';

class DescriptionTable extends Component {
  state = {}
  render() {
    return (
      <div className="asset-info-container">
        <h1 className="asset-info-title">Dados Gerais</h1>
        <div className="asset-info-content">
          <Row>
            <Col md="6">
              <div className="asset-info-single-container">
                <div className="desc-sub">Nome do Edifício ou Área</div>
                <div className="asset-info-content-data">{assetsInfo.assetByAssetSf.name || "Não cadastrado"}</div>
              </div>
              <div className="asset-info-single-container">
                <div className="desc-sub">Código</div>
                <div className="asset-info-content-data">{assetsInfo.assetByAssetSf.assetSf || "Não cadastrado"}</div>
              </div>
            </Col>
            <Col md="6">
              <div className="asset-info-single-container">
                <div className="desc-sub">Departamento (s)</div>
                <div className="asset-info-content-data">{/*departments.map(item => (item.node.departmentByDepartmentId.departmentId)).join(' / ')*/ false || "Não cadastrado"}</div>
              </div>
            </Col>
          </Row>
          <div className="asset-info-container">
            <div className="asset-info-single-container">
              <div className="desc-sub">Descrição do Edifício</div>
              <div className="asset-info-content-data">{assetsInfo.assetByAssetSf.description || "Não cadastrado"}</div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default DescriptionTable;