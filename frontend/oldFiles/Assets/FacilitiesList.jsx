import React, { Component } from 'react';
import TableWithPages from "../../components/Tables/TableWithPages";
import AssetCard from "../../components/Cards/AssetCard";
import ModalCreateFilter from "../../components/Modals/ModalCreateFilter";
import ApplyFilter from "../../components/Modals/ApplyFilter"
import {
  Badge,
  Button,
  Row,
  Col,
  InputGroupText,
  CustomInput,
  InputGroup,
  InputGroupAddon,
  Input,
} from "reactstrap";
import { withRouter } from "react-router-dom";
import "./List.css";

import { facilityConfig } from "./AssetsFakeData";
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
    name: "Edifícios - Blocos de Apoio",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'name', type: 'att', verb: 'include', term: ["Bloco"] },
    ],
  },
  {
    id: "003",
    name: "Edifícios -  Áreas Técnicas",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["AT"] },
    ],
  },
  {
    id: "004",
    name: "Apartamentos Funcionais - SQS 309",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["309"] },
    ],
  },
  {
    id: "005",
    name: "SQS 309 - Bloco C",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["309C"] },
    ],
  },
  {
    id: "006",
    name: "SQS 309 - Bloco D",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["309D"] },
    ],
  },
  {
    id: "007",
    name: "SQS 309 - Bloco G",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["309G"] },
    ],
  },
  {
    id: "008",
    name: "Residência Oficial",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["SHIS"] },
    ],
  },
  {
    id: "009",
    name: "Edifícios- Anexo I",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["AX01"] },
    ],
  },
  {
    id: "010",
    name: "Edifícios- Anexo II",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'assetSf', type: 'att', verb: 'include', term: ["AX02"] },
    ],
  },
  {
    id: "011",
    name: "Vias do CASF",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'name', type: 'att', verb: 'include', term: ["Via"] },
    ],
  },
  {
    id: "012",
    name: "Edifícios - Alas do CASF",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'name', type: 'att', verb: 'include', term: ["Ala"] },
    ],
  },
  {
    id: "013",
    name: "Blocos - Com área maior que 1000 m²",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'name', type: 'att', verb: 'include', term: ["Bloco"] },
      { attribute: 'and', type: 'opr', verb: null, term: [] },
      { attribute: 'area', type: 'att', verb: 'greaterThan', term: ["1000"] },
    ],
  },
];

const attributes = [
  'assetSf',
  'name',
  'area',
];

const filterAttributes = {
  assetSf: { name: 'Código', type: 'text' },
  name: { name: 'Nome', type: 'text' },
  description: { name: 'Descrição', type: 'text' },
  area: { name: 'Área', type: 'number' }
};

class FacilitiesList extends Component {
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
    this.props.history.push('/ativos/edificios/novo');
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

    let filteredItems = filterLogic.length > 0 ? filterList(allEdges, filterLogic) : allEdges;
    let searchedItems = searchList(filteredItems, attributes, searchTerm);

    const pagesTotal = Math.floor(searchedItems.length / ENTRIES_PER_PAGE) + 1;
    const showItems = searchedItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

    const thead =
      <tr>
        <th className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </th>
        {facilityConfig.map(column => (
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
        {/* <td className="text-center">{item.node.parent}</td> */}
        <td>
          <div className="text-center">{item.node.area}</div>
        </td>
        <td>
          <div className="text-center">
            <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
          </div>
        </td>
      </tr>))

    return (
      <div className="card-container">
        <AssetCard
          sectionName={'Edifícios e áreas'}
          sectionDescription={'Endereçamento do Senado Federal'}
          handleCardButton={this.handleURLChange}
          buttonName={'Cadastrar Área'}
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

export default withRouter(FacilitiesList);