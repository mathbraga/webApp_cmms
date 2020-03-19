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

import { tableConfig } from "./WorkOrdersTableConfig";
import searchList from "../../utils/search/searchList";
import filterList from "../../utils/filter/filter";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

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
    name: "OS - Reparo em forro",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["FOR"] },
    ],
  },
  {
    id: "003",
    name: "OS - Avaliação estrutural",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["EST"] },
    ],
  },
  {
    id: "004",
    name: "OS - Infiltração",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["INF"] },
    ],
  },
  {
    id: "005",
    name: "OS - Instalações elétricas",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["ELE"] },
    ],
  },
  {
    id: "006",
    name: "OS - Instalações hidrossanitárias",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["HID"] },
    ],
  },
  {
    id: "007",
    name: "OS - Marcenaria",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["MAR"] },
    ],
  },
  {
    id: "008",
    name: "OS - Reparo em piso",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["PIS"] },
    ],
  },
  {
    id: "009",
    name: "OS - Avaliação estrutural",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["EST"] },
    ],
  },
  {
    id: "010",
    name: "OS - Revestimento",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["REV"] },
    ],
  },
  {
    id: "011",
    name: "OS - Vedação espacial",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["VED"] },
    ],
  },
  {
    id: "012",
    name: "OS - Vidraçaria / Esquadria",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["VID"] },
    ],
  },
  {
    id: "013",
    name: "OS - Serralheria",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["SER"] },
    ],
  },
  {
    id: "014",
    name: "OS - Ar-condicionado",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["ARC"] },
    ],
  },
  {
    id: "015",
    name: "OS - Elevadores",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["ELV"] },
    ],
  },
  {
    id: "016",
    name: "OS - Exaustores",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["EXA"] },
    ],
  },
  {
    id: "017",
    name: "OS - Revestimento",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["REV"] },
    ],
  },
  {
    id: "018",
    name: "OS - Serviços Gerais",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'category', type: 'att', verb: 'sameChoice', term: ["GRL"] },
    ],
  },
  {
    id: "019",
    name: "OS - Canceladas",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'status', type: 'att', verb: 'sameChoice', term: ["CAN"] },
    ],
  },
  {
    id: "020",
    name: "OS - Suspensas",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'status', type: 'att', verb: 'sameChoice', term: ["SUS"] },
    ],
  },
  {
    id: "021",
    name: "OS - Execução",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'status', type: 'att', verb: 'sameChoice', term: ["EXE"] },
    ],
  },
  {
    id: "022",
    name: "OS - Concluídas",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'status', type: 'att', verb: 'sameChoice', term: ["CON"] },
    ],
  },
  {
    id: "023",
    name: "OS - Execução ou Fila de Espera",
    author: "webSINFRA Software",
    logic: [
      { attribute: 'status', type: 'att', verb: 'sameChoice', term: ["EXE", "FIL"] },
    ],
  },

];

const attributes = [
  'category',
  'orderId',
  'dateLimit',
  'status',
  'title',
  'place'
];

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

const filterAttributes = {
  category: { name: 'Categoria', type: 'option', options: ORDER_CATEGORY_TYPE },
  description: { name: 'Descrição', type: 'text' },
  place: { name: 'Localização', type: 'text' },
  priority: { name: 'Prioridade', type: 'option', options: ORDER_PRIORITY_TYPE },
  status: { name: 'Status', type: 'option', options: ORDER_STATUS_TYPE },
  title: { name: 'Título', type: 'text' },
};

class WorkOrdersList extends Component {
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
    this.props.history.push('/manutencao/os/nova');
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
    const allEdges = allItems.allOrders.edges;

    console.log("Work Order: ", allEdges[0]);

    let filteredItems = filterLogic.length > 0 ? filterList(allEdges, filterLogic) : allEdges;
    let searchedItems = searchList(filteredItems, attributes, searchTerm);

    const pagesTotal = Math.floor(searchedItems.length / ENTRIES_PER_PAGE) + 1;
    const showItems = searchedItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

    // Create array with all places:
    const places = {};
    showItems.forEach(item => {
      const tempPlaces = []
      item.node.orderAssetsByOrderId.edges.forEach(asset => {
        tempPlaces.push(asset.node.assetByAssetId.assetSf);
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

    const tbody = showItems.map(item => (
      <tr
        onClick={() => { this.props.history.push('/manutencao/os/view/' + item.node.orderId) }}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td className="text-center">{item.node.orderId.toString().padStart(3, "0")}</td>
        <td>
          <div>{item.node.title}</div>
          <div className="small text-muted">{ORDER_CATEGORY_TYPE[item.node.category]}</div>
        </td>
        <td className="text-center">{ORDER_STATUS_TYPE[item.node.status]}</td>
        <td>
          <div className="text-center">{item.node.dateLimit && item.node.dateLimit.split('T')[0]}</div>
        </td>
        <td>
          <div className="text-center">
            {item.node.place}
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

export default withRouter(WorkOrdersList);