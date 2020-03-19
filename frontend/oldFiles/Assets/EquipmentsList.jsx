import React, { Component } from 'react';
import ModalCreateFilter from "../../components/Modals/ModalCreateFilter";
import ApplyFilter from "../../components/Modals/ApplyFilter";
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

import { equipmentConfig } from "./AssetsFakeData";
import searchList from "../../utils/search/searchList";
import filterList from "../../utils/filter/filter";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

const mapIcon = require("../../assets/icons/map.png");

const ENTRIES_PER_PAGE = 15;

const customFilters = [
  {
    id: "001",
    name: "Sem Filtro",
    author: "webSINFRA Software",
    logic: [],
  },
  {
    id: "002",
    name: "Ativos - Elétrica",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["ELET"] },
    ],
  },
  {
    id: "003",
    name: "Ativos - Civil",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["CIVL"] },
    ],
  },
  {
    id: "004",
    name: "Ativos - Mecânica",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["MECN"] },
    ],
  },
  {
    id: "005",
    name: "Elétrica - Quadros",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'name', type: 'att', verb: 'include', term: ["Quadro"] },
    ],
  },
  {
    id: "006",
    name: "Elétrica - Estações Transformadoras",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'name', type: 'att', verb: 'include', term: ["Estação"] },
    ],
  },
  {
    id: "007",
    name: "Elétrica - No breaks",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'name', type: 'att', verb: 'include', term: ["No break"] },
    ],
  },
];

const attributes = [
  'assetSf',
  'name',
  'manufacturer',
  'model',
];

const filterAttributes = {
  assetSf: { name: 'Código', type: 'text' },
  manufacturer: { name: 'Fabricante', type: 'text' },
  model: { name: 'Modelo', type: 'text' },
  name: { name: 'Nome', type: 'text' },
  serialnum: { name: 'Número serial', type: 'text' },
};

class EquipmentsList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      pageCurrent: 1,
      goToPage: 1,
      searchTerm: "",
      modalFilter: false,
      modalApplyFilter: false,
      filterLogic: [],
      filterName: null,
      filterSavedId: null,
    };

    this.setGoToPage = this.setGoToPage.bind(this);
    this.setCurrentPage = this.setCurrentPage.bind(this);
    this.handleChangeSearchTerm = this.handleChangeSearchTerm.bind(this);
    this.handleURLChange = this.handleURLChange.bind(this);
    this.toggleCreate = this.toggleCreate.bind(this);
    this.toggleApply = this.toggleApply.bind(this);
  }

  toggleCreate() {
    this.setState((prevState) => ({
      modalFilter: !prevState.modalFilter
    }));
  }

  toggleApply() {
    this.setState((prevState) => ({
      modalApplyFilter: !prevState.modalApplyFilter
    }));
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
    this.props.history.push('/ativos/equipamentos/novo');
  }

  updateCurrentFilter = (filterLogic, filterName, filterId = null) => {
    this.setState({
      filterLogic,
      filterName,
      filterSavedId: filterId,
      pageCurrent: 1,
      goToPage: 1,
    });
  }

  render() {
    const { allItems } = this.props;
    const { pageCurrent, goToPage, searchTerm, filterLogic } = this.state;
    const allEdges = allItems.allAssets.edges;

    let filteredItems = filterLogic.length > 0 ? filterList(allEdges, filterLogic) : allEdges;;
    let searchedItems = searchList(filteredItems, attributes, searchTerm);

    const pagesTotal = Math.floor(searchedItems.length / ENTRIES_PER_PAGE) + 1;
    const showItems = searchedItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

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
        onClick={() => { this.props.history.push('/ativos/view/' + item.node.assetSf) }}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td>
          <div>{item.node.name}</div>
          <div className="small text-muted">{item.node.assetSf}</div>
        </td>
        {/* <td className="text-center">{item.node.assetByPlace.name}</td> */}
        <td className="text-center">{item.node.manufacturer}</td>
        <td className="text-center">{item.node.model}</td>
        {/* <td className="text-center">{item.node.assetByParent.assetId}</td> */}
      </tr>))

    return (
      <div className="card-container">
        <AssetCard
          sectionName={'Equipamentos'}
          sectionDescription={'Lista de equipamentos'}
          handleCardButton={this.handleURLChange}
          buttonName={'Novo Equipamento'}
        >
          <div className="card-search-container">
            <div className="search" style={{ width: "30%" }}>
              <div className="card-search-form">
                <InputGroup>
                  <Input placeholder="Pesquisar ..." value={searchTerm} onChange={this.handleChangeSearchTerm} />
                  <InputGroupAddon addonType="append">
                    <InputGroupText><img src={searchItem} alt="Search Item" style={{ width: "19px", height: "16px", margin: "3px 0px" }} /></InputGroupText>
                  </InputGroupAddon>
                </InputGroup>
              </div>
            </div>
            <div className="search-filter" style={{ width: "30%" }}>
              <ol>
                <li><span className="card-search-title">Filtro: </span></li>
                <li><span className="card-search-title">Resultado: </span></li>
              </ol>
              <ol>
                <li>{(this.state.filterLogic.length === 0) ? "Sem filtro" : (this.state.filterName || "Filtro sem nome")}</li>
                <li><span>Página com </span><b>{filteredItems.length.toString()}</b><span> itens</span></li>
              </ol>
            </div>
            <div className="search-buttons" style={{ width: "30%" }}>
              <Button className="search-filter-button" color="success" onClick={this.toggleApply}>Aplicar Filtro</Button>
              <Button className="search-filter-button" color="primary" onClick={this.toggleCreate}>Criar Filtro</Button>
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
          <ModalCreateFilter
            toggle={this.toggleCreate}
            modal={this.state.modalFilter}
            attributes={filterAttributes}
            updateCurrentFilter={this.updateCurrentFilter}
          />
          <ApplyFilter
            toggle={this.toggleApply}
            modal={this.state.modalApplyFilter}
            attributes={filterAttributes}
            updateCurrentFilter={this.updateCurrentFilter}
            customFilters={customFilters}
            currentFilterId={this.state.filterSavedId}
          />
        </AssetCard >
      </div>
    );
  }
}

export default withRouter(EquipmentsList);