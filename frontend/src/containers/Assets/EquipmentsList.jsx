import React, { Component } from 'react';
import { Row, Col, Button, } from "reactstrap";
import TableWithPages from "../../components/Tables/TableWithPages";
import AssetCard from "../../components/Cards/AssetCard";
import { CustomInput } from "reactstrap";
import { withRouter } from "react-router-dom";
import "./List.css";

import { equipmentConfig } from "./AssetsFakeData";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

const mapIcon = require("../../assets/icons/map.png");

const ENTRIES_PER_PAGE = 15;

class EquipmentsList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      pageCurrent: 1,
      goToPage: 1,
      searchTerm: ""
    };

    this.setGoToPage = this.setGoToPage.bind(this);
    this.setCurrentPage = this.setCurrentPage.bind(this);
    this.handleChangeSearchTerm = this.handleChangeSearchTerm.bind(this);
    this.handleURLChange = this.handleURLChange.bind(this);
  }

  handleChangeSearchTerm(event) {
    this.setState({ searchTerm: event.target.value, pageCurrent: 1, goToPage: 1 });
  }

  setGoToPage(page) {
    this.setState({ goToPage: page });
  }

  setCurrentPage(pageCurrent) {
    this.setState({ pageCurrent: pageCurrent }, () => {
      this.setState({ goToPage: pageCurrent });
    });
  }

  handleURLChange(){
    this.props.history.push('/ativos/equipamentos/novo');
  }

  render() {
    const { allItems } = this.props;
    const { pageCurrent, goToPage, searchTerm } = this.state;
    const allEdges = allItems.allAssets.edges;

    let filteredItems = allEdges;
    if (searchTerm.length > 0) {
      const searchTermLower = searchTerm.toLowerCase();
      filteredItems = allEdges.filter(function (item) {
        return (
          item.node.assetId.toLowerCase().includes(searchTermLower) ||
          item.node.name.toLowerCase().includes(searchTermLower) ||
          item.node.parent.toLowerCase().includes(searchTermLower) ||
          item.node.model.toLowerCase().includes(searchTermLower)
        );
      });
    }

    console.log("Filtered Items:");
    console.log(filteredItems);

    const pagesTotal = Math.floor(filteredItems.length / ENTRIES_PER_PAGE) + 1;
    const showItems = filteredItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

    const thead =
      <tr>
        <th className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </th>
        {equipmentConfig.map(column => (
          <th style={column.style} className={column.className}>{column.description}</th>))
        }
      </tr>

    const tbody = showItems.map(item => (
      <tr
        onClick={() => { this.props.history.push('/ativos/view/' + item.node.assetId) }}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td>
          <div>{item.node.assetId}</div>
          <div className="small text-muted">{item.node.parent}</div>
        </td>
        <td className="text-center">{item.node.manufacturer}</td>
        <td className="text-center">{item.node.model}</td>
        <td>
          <div className="text-center">
            {item.node.serialnum}
          </div>
        </td>
      </tr>))

    return (
      <AssetCard
        sectionName={'Equipamentos'}
        sectionDescription={'Lista de equipamentos'}
        handleCardButton={this.handleURLChange}
        buttonName={'Novo Equipamento'}
      >
        <Row style={{ marginTop: "10px", marginBottom: "5px" }}>
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
                <input placeholder="Pesquisar ..." value={searchTerm} onChange={this.handleChangeSearchTerm} />
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
            <TableWithPages
              thead={thead}
              tbody={tbody}
              pagesTotal={pagesTotal}
              pageCurrent={pageCurrent}
              goToPage={goToPage}
              setCurrentPage={this.setCurrentPage}
              setGoToPage={this.setGoToPage}
            />
          </Col>
        </Row>
      </AssetCard >
    );
  }
}

export default withRouter(EquipmentsList);