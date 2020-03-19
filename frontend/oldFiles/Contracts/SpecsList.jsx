import React, { Component } from 'react';
import ModalCreateFilter from "../../components/Modals/ModalCreateFilter";
import ApplyFilter from "../../components/Modals/ApplyFilter"
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

import searchList from "../../utils/search/searchList";
import filterList from "../../utils/filter/filter";
// import { materials } from "./FakeData";

const tableConfig = [
  { name: "Material / Serviço", style: { width: "300px" }, className: "text-justify" },
  { name: "Categoria", style: { width: "200px" }, className: "text-center" },
  { name: "Subcategoria", style: { width: "200px" }, className: "text-center" },
  // { name: "Disponível", style: { width: "100px" }, className: "text-center" },
];

const searchItem = require("../../assets/icons/search_icon.png");

const ENTRIES_PER_PAGE = 15;

const attributes = [
  "specSf",
  "subcategory",
  "name",
  "category"
];

const customFilters = [
  {
    id: "001",
    name: "Sem Filtro",
    author: "webSINFRA Software",
    logic: [],
  },
  {
    id: "002",
    name: "Geral",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Geral"] },
    ],
  },
  {
    id: "003",
    name: "Civil",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Civil"] },
    ],
  },
  {
    id: "004",
    name: "Serviços de Apoio",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Serviços de Apoio"] },
    ],
  },
  {
    id: "005",
    name: "Elétrica",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Elétrica"] },
    ],
  },
  {
    id: "006",
    name: "Hidrossanitário",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Hidrossanitário"] },
    ],
  },
  {
    id: "007",
    name: "Ar Condicionado",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Ar Condicionado"] },
    ],
  },
  {
    id: "008",
    name: "Marcenaria e Serralheria",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Marcenaria e Serralheria"] },
    ],
  },
  {
    id: "009",
    name: "Rede e Telefonia",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Rede e Telefonia"] },
    ],
  },
  {
    id: "010",
    name: "Ferramentas e Equipamentos",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["Ferramentas e Equipamentos"] },
    ],
  },
];

const SPECS_CATEGORY = {
  'Geral': 'Geral',
  'Serviços de Apoio': 'Serviços de Apoio',
  'Civil': 'Civil',
  'Hidrossanitário': 'Hidrossanitário',
  'Elétrica': 'Elétrica',
  'Ar Condicionado': 'Ar Condicionado',
  'Marcenaria e Serralheria': 'Marcenaria e Serralheria',
  'Rede e Telefonia': 'Rede e Telefonia',
  'Ferramentas e Equipamentos': 'Ferramentas e Equipamentos',
}

const filterAttributes = {
  category: { name: 'Categoria', type: 'option', options: SPECS_CATEGORY },
  name: { name: 'Material / Serviço', type: 'text' },
  specSf: { name: 'Código', type: 'text' },
  subcategory: { name: 'Subcategoria', type: 'text' },
  version: { name: 'Versão', type: 'text' },
};

class SpecsList extends Component {
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
    this.props.history.push('/gestao/servicos/novo');
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

    let filteredItems = filterLogic.length > 0 ? filterList(allItems, filterLogic) : allItems;
    let searchedItems = searchList(filteredItems, attributes, searchTerm);

    const pagesTotal = Math.floor(searchedItems.length / ENTRIES_PER_PAGE) + 1;
    const showItems = searchedItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

    const thead =
      <tr>
        <th className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </th>
        {tableConfig.map(column => (
          <th style={column.style} className={column.className}>{column.name}</th>))
        }
      </tr>

    const tbody = showItems.map(item => (
      <tr
        onClick={() => { this.props.history.push('/gestao/servicos/view/' + item.specId) }}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td>
          <div>{item.name}</div>
          <div className="small text-muted">{item.specSf}</div>
        </td>
        <td className="text-center">{item.category}</td>
        <td>
          <div className="text-center">{item.subcategory}</div>
        </td>
        {/* <td>
          <div className="text-center">
            {item.qtd.toString() + " " + item.unit}
          </div>
        </td> */}
      </tr>))

    return (
      <div className="card-container">
        <AssetCard
          sectionName={'Especificações Técnicas'}
          sectionDescription={'Lista de especiicações técnicas'}
          handleCardButton={this.handleURLChange}
          buttonName={'Cadastrar Especificação Técnica'}
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

export default withRouter(SpecsList);