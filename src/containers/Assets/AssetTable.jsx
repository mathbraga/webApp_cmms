import React, { Component } from 'react';
import { Row, Col, Button, } from "reactstrap";
import TableItems from "../../components/Tables/Table";
import AssetCard from "../../components/Cards/AssetCard";
import "./AssetTable.css";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

const tableConfig = [
  { name: "Localização", style: { width: "400px" }, className: "" },
  { name: "Código", style: { width: "200px" }, className: "text-center" },
  { name: "Visitação", style: { width: "150px" }, className: "text-center" },
  { name: "Área", style: { width: "150px" }, className: "text-center" },
  { name: "Planta", style: { width: "100%" }, className: "text-center" },
];

const locationItems = [
  { location: "Edifício Principal", parent: "Complexo Arquitetônico do Senado Federal", code: "EDP-ANX-000", visiting: "sim", area: "1200" },
  { location: "Gabinete do Senador José Serra", parent: "Edifício Anexo I", code: "GBN-ANX-025", visiting: "não", area: "100" },
  { location: "Diretoria da SINFRA", parent: "Bloco 14", code: "DIR-BLC-012", visiting: "não", area: "70" },
  { location: "Edifício Principal", parent: "Complexo Arquitetônico do Senado Federal", code: "EDP-ANX-000", visiting: "sim", area: "1200" },
  { location: "Gabinete do Senador José Serra", parent: "Edifício Anexo I", code: "GBN-ANX-025", visiting: "não", area: "100" },
  { location: "Diretoria da SINFRA", parent: "Bloco 14", code: "DIR-BLC-012", visiting: "não", area: "70" },
  { location: "Edifício Principal", parent: "Complexo Arquitetônico do Senado Federal", code: "EDP-ANX-000", visiting: "sim", area: "1200" },
  { location: "Gabinete do Senador José Serra", parent: "Edifício Anexo I", code: "GBN-ANX-025", visiting: "não", area: "100" },
  { location: "Diretoria da SINFRA", parent: "Bloco 14", code: "DIR-BLC-012", visiting: "não", area: "70" },
  { location: "Edifício Principal", parent: "Complexo Arquitetônico do Senado Federal", code: "EDP-ANX-000", visiting: "sim", area: "1200" },
  { location: "Gabinete do Senador José Serra", parent: "Edifício Anexo I", code: "GBN-ANX-025", visiting: "não", area: "100" },
  { location: "Diretoria da SINFRA", parent: "Bloco 14", code: "DIR-BLC-012", visiting: "não", area: "70" },
  { location: "Edifício Principal", parent: "Complexo Arquitetônico do Senado Federal", code: "EDP-ANX-000", visiting: "sim", area: "1200" },
  { location: "Gabinete do Senador José Serra", parent: "Edifício Anexo I", code: "GBN-ANX-025", visiting: "não", area: "100" },
  { location: "Diretoria da SINFRA", parent: "Bloco 14", code: "DIR-BLC-012", visiting: "não", area: "70" },
];

class AssetTable extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <AssetCard
        sectionName={'Edifícios e áreas'}
        sectionDescription={'Endereçamento do Senado Federal'}
        handleCardButton={() => { }}
        buttonName={'Cadastrar Área'}
      >
        <Row style={{ marginTop: "10px", marginBottom: "15px" }}>
          <Col md="2">
            <Button
              color="dark"
              className="button-inside"
              outline
              style={{ marginLeft: "10px" }}
            >
              <img src={hierarchyItem} alt="" style={{ width: "100%", height: "100%" }} />
            </Button>
            <Button
              color="dark"
              className="button-inside"
              outline
              style={{ marginLeft: "20px" }}
            >
              <img src={listItem} alt="" style={{ width: "100%", height: "100%" }} />
            </Button>
          </Col>
          <Col md="4">
            <form>
              <div className="search-input" >
                <input placeholder="Pesquisar ..." />
                <img src={searchItem} alt="" style={{ width: "18px", height: "15px", margin: "3px 0px" }} />
              </div>
            </form>
            <div style={{ color: "blue", textDecoration: "underline", marginLeft: "10px", fontSize: "12.4px" }}>
              Pesquisa Avançada
            </div>
          </Col>
          <Col md="6">
          </Col>
        </Row>
        <Row>
          <Col>
            <div style={{ display: "flex", justifyContent: "flex-end", paddingRight: "10px", margin: "5px 5px" }}>Página 10 de 10</div>
          </Col>
        </Row>
        <Row>
          <Col>
            <TableItems tableConfig={tableConfig} items={locationItems} />
          </Col>
        </Row>
      </AssetCard >
    );
  }
}

export default AssetTable;