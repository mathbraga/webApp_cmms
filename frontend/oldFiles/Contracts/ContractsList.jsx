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

import searchList from "../../utils/search/searchList";
import filterList from "../../utils/filter/filter";
// import { contracts } from "./FakeData";

const tableConfig = [
  { name: "Número", style: { width: "100px" }, className: "text-center" },
  { name: "Objeto", style: { width: "300px" }, className: "text-justify" },
  { name: "Status", style: { width: "150px" }, className: "text-center" },
  { name: "Vigência", style: { width: "150px" }, className: "text-center" },
  { name: "Link", style: { width: "100px" }, className: "text-center" },
];

const searchItem = require("../../assets/icons/search_icon.png");

const ENTRIES_PER_PAGE = 15;

const attributes = [
  "contractSf",
  "title",
  "company",
  "status",
  "dateStart",
  "finalDate"
];

const customFilters = [
  {
    id: "001",
    name: "Sem Filtro",
    author: "webSINFRA Software",
    logic: [],
  },
];

const CONTRACT_STATUS = {
  'EXE': 'Execução',
};

const filterAttributes = {
  company: { name: 'Contratada', type: 'text' },
  contractSf: { name: 'Contrato nº', type: 'text' },
  status: { name: 'Status', type: 'option', options: CONTRACT_STATUS },
  title: { name: 'Título', type: 'text' }
};

class ContractsList extends Component {
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
    this.props.history.push('/gestao/contratos/novo');
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
        onClick={() => { this.props.history.push('/gestao/contratos/view/' + item.contractSf) }}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td className="text-center">{item.contractSf}</td>
        <td>
          <div>{item.title}</div>
          <div className="small text-muted">{item.company}</div>
        </td>
        <td className="text-center">{CONTRACT_STATUS[item.status]}</td>
        <td>
          <div className="text-center">{item.dateStart + ' a ' + item.dateEnd}</div>
        </td>
        <td>
          <div className="text-center">
            <a
              href={item.url}
              target="_blank"
              rel="noopener noreferrer nofollow"
              onClick={(e) => e.stopPropagation()}
            >
              {"CT " + parseInt(item.contractSf.slice(2, 6), 10) + "/" + item.contractSf.slice(6)}
            </a>
          </div>
        </td>
      </tr>))

    return (
      <div className="card-container">
        <AssetCard
          sectionName={'Contratos da Sinfra'}
          sectionDescription={'Lista com os contratos de engenharia'}
          handleCardButton={this.handleURLChange}
          buttonName={'Cadastrar Contrato'}
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

export default withRouter(ContractsList);