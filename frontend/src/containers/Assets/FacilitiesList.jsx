import React, { Component } from 'react';
import TableWithPages from "../../components/Tables/TableWithPages";
import AssetCard from "../../components/Cards/AssetCard";
import ModalCreateFilter from "../../components/Modals/ModalCreateFilter"
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

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

const mapIcon = require("../../assets/icons/map.png");

const ENTRIES_PER_PAGE = 15;
const attributes = [
  'assetSf',
  'name',
  // 'parent',
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
      filterLogic: [
        { type: 'att', attribute: 'name', verb: 'include', term: ['SQS', 'C'] },
        { type: 'opr', attribute: null, verb: 'and', term: [] },
        { type: 'att', attribute: 'assetSf', verb: 'notInclude', term: ['cob'] }
      ],
    };

    this.setGoToPage = this.setGoToPage.bind(this);
    this.setCurrentPage = this.setCurrentPage.bind(this);
    this.handleChangeSearchTerm = this.handleChangeSearchTerm.bind(this);
    this.handleURLChange = this.handleURLChange.bind(this);
    this.toggle = this.toggle.bind(this);
  }

  toggle() {
    this.setState((prevState) => ({
      modalFilter: !prevState.modalFilter
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

  cleanFilter = () => {
    this.setState({
      filterLogic: [],
    });
  }

  buildFilter = (logicState) => () => {
    const { attribute, operator, option } = logicState;
    let term = [];

    if (!attribute || attribute === '') {
      return;
    }
    if (!operator || operator === '') {
      return;
    }
    if (!option || option === '' || option === []) {
      return;
    }

    if (filterAttributes[attribute].type === 'text') {
      option.split(" ").forEach(element => {
        term.push(element);
      });
    } else {
      term.push(option);
    }

    const newLogic = {
      type: (operator === 'and' || operator === 'or' ? 'opr' : 'att'),
      attribute,
      verb: operator,
      term,
    };

    this.setState((prevState) => ({
      filterLogic: [...prevState.filterLogic, newLogic],
    }));
  }

  render() {
    const { allItems } = this.props;
    const { pageCurrent, goToPage, searchTerm } = this.state;

    const allEdges = allItems.allAssets.edges;

    let filteredItems = allEdges;
    filteredItems = searchList(allEdges, attributes, searchTerm);

    const pagesTotal = Math.floor(filteredItems.length / ENTRIES_PER_PAGE) + 1;
    const showItems = filteredItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

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
              <Button className="search-filter-button" color="primary" onClick={this.toggle}>Criar Filtro</Button>
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
            toggle={this.toggle}
            modal={this.state.modalFilter}
            attributes={filterAttributes}
            filterLogic={this.state.filterLogic}
            buildFilter={this.buildFilter}
            cleanFilter={this.cleanFilter}
          />
        </AssetCard >
      </div>
    );
  }
}

export default withRouter(FacilitiesList);