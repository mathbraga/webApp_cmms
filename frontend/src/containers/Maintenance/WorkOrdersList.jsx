import React, { Component } from 'react';
import {
  Row,
  Col,
  Button,
  CustomInput,
  InputGroup,
  Input,
  InputGroupAddon,
  InputGroupText,
} from "reactstrap";
import TableWithPages from "../../components/Tables/TableWithPages";
import AssetCard from "../../components/Cards/AssetCard";
import { withRouter } from "react-router-dom";
import "./List.css";

import { tableConfig } from "./WorkOrdersTableConfig";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

const ENTRIES_PER_PAGE = 15;

const ORDER_CATEGORY_TYPE = {
  'EST': 'Avaliação estrutural',
  'FOR': 'Reparo em forro',
  'INF': 'Infiltração',
  'ELE': 'Instalações elétricas',
  'HID': 'Instalações hidrossanitárias',
  'MAR': 'Marcenaria',
  'PIS': 'Reparo em piso',
  'REV': 'Revestimento',
  'VED': 'Vedação espacial',
  'VID': 'Vidraçaria / Esquadria',
  'SER': 'Serralheria',
  'ARC': 'Ar-condicionado',
  'ELV': 'Elevadores',
  'EXA': 'Exaustores',
  'GRL': 'Serviços Gerais',
};

const ORDER_STATUS_TYPE = {
  'CAN': 'Cancelada',
  'NEG': 'Negada',
  'PEN': 'Pendente',
  'SUS': 'Suspensa',
  'FIL': 'Fila de espera',
  'EXE': 'Execução',
  'CON': 'Concluída',
}

const ORDER_PRIORITY_TYPE = {
  'BAI': 'Baixa',
  'NOR': 'Normal',
  'ALT': 'Alta',
  'URG': 'Urgente',
};


class WorkOrdersList extends Component {
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

  handleURLChange() {
    this.props.history.push('/manutencao/os/nova');
  }

  render() {
    const { allItems } = this.props;
    const { pageCurrent, goToPage, searchTerm } = this.state;
    const allEdges = allItems.allOrders.edges;

    let filteredItems = allEdges;
    if (searchTerm.length > 0) {
      const searchTermLower = searchTerm.toLowerCase();
      filteredItems = allEdges.filter(function (item) {

        const dateLimit = item.node.dateLimit === null ? "" : item.node.dateLimit;
        const requestLocal = item.node.requestLocal === null ? "" : item.node.requestLocal;

        return (
          (ORDER_CATEGORY_TYPE[item.node.category] && ORDER_CATEGORY_TYPE[item.node.category].toLowerCase().includes(searchTermLower)) ||
          (String(item.node.orderId).padStart(3,"0").includes(searchTermLower)) ||
          (String(dateLimit) && String(dateLimit).includes(searchTermLower)) ||
          (ORDER_STATUS_TYPE[item.node.status] && ORDER_STATUS_TYPE[item.node.status].toLowerCase().includes(searchTermLower)) ||
          (item.node.requestTitle.toLowerCase().includes(searchTermLower)) ||
          (requestLocal && requestLocal.toLowerCase().includes(searchTermLower))
        );
      });
    }

    const pagesTotal = Math.floor(filteredItems.length / ENTRIES_PER_PAGE) + 1;
    const showItems = filteredItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

    // Create array with all places:
    const places = {};
    showItems.forEach(item => {
      const tempPlaces = []
      item.node.orderAssetsByOrderId.edges.forEach(asset => {
        tempPlaces.push(asset.node.assetByAssetId.assetByPlace);
      });
      if (tempPlaces.length > 0) { places[item.node.orderId] = tempPlaces; }
    });

    const thead =
      <tr>
        <th className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </th>
        {tableConfig.map(column => (
          <th style={column.style} className={column.className}>{column.name}</th>))
        }
      </tr>

    console.log("Show Items: ", showItems);
    const tbody = showItems.map(item => (
      <tr
        onClick={() => { this.props.history.push('/manutencao/os/view/' + item.node.orderId) }}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td className="text-center">{item.node.orderId.toString().padStart(3,"0")}</td>
        <td>
          <div>{item.node.requestTitle}</div>
          <div className="small text-muted">{ORDER_CATEGORY_TYPE[item.node.category]}</div>
        </td>
        <td className="text-center">{ORDER_STATUS_TYPE[item.node.status]}</td>
        <td>
          <div className="text-center">{item.node.dateLimit && item.node.dateLimit.split('T')[0]}</div>
        </td>
        <td>
          <div className="text-center">
            {item.node.requestLocal}
          </div>
        </td>
      </tr>))

    return (
      <div className="card-container">
        <AssetCard
          sectionName={'Ordens de Serviço'}
          sectionDescription={'Lista com ordens de serviço'}
          handleCardButton={this.handleURLChange}
          buttonName={'Cadastrar OS'}
        >
          <div className="card-search-container">
            <div className="search" style={{ width: "30%" }}>
              <div className="card-search-form">
                <InputGroup>
                  <Input placeholder="Pesquisar ..." value={searchTerm} onChange={this.handleChangeSearchTerm} />
                  <InputGroupAddon addonType="append">
                    <InputGroupText><img src={searchItem} alt="" style={{ width: "19px", height: "16px", margin: "3px 0px" }} /></InputGroupText>
                  </InputGroupAddon>
                </InputGroup>
              </div>
            </div>
            <div className="search-filter" style={{ width: "30%" }}>
              <ol>
                <li><span className="card-search-title">Filtro: </span></li>
                <li><span className="card-search-title">Regras: </span></li>
              </ol>
              <ol>
                <li>Sem filtro</li>
                <li>Mostrar todos itens</li>
              </ol>
            </div>
            <div className="search-buttons" style={{ width: "30%" }}>
              <Button className="search-filter-button" color="success">Aplicar Filtro</Button>
              <Button className="search-filter-button" color="primary">Criar Filtro</Button>
            </div>
          </div>
          <TableWithPages
            thead={thead}
            tbody={tbody}
            pagesTotal={pagesTotal}
            pageCurrent={pageCurrent}
            goToPage={goToPage}
            setCurrentPage={this.setCurrentPage}
            setGoToPage={this.setGoToPage}
          />
        </AssetCard >
      </div>
    );
  }
}

export default withRouter(WorkOrdersList);