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

// import { persons } from "./FakeData";

const tableConfig = [
  { name: "Nome da equipe", style: { width: "300px" }, className: "text-justify" },
  { name: "Número de membros", style: { width: "150px" }, className: "text-center" },
  // { name: "Descrição", style: { width: "150px" }, className: "text-center" },
  // { name: "E-mail", style: { width: "200px" }, className: "text-center" },
];

const searchItem = require("../../assets/icons/search_icon.png");

const ENTRIES_PER_PAGE = 15;

class TeamsList extends Component {
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
    this.props.history.push('/gestao/servicos/novo');
  }

  render() {
    const { allItems } = this.props;
    const { pageCurrent, goToPage, searchTerm } = this.state;

    let filteredItems = allItems;
    if (searchTerm.length > 0) {
      const searchTermLower = searchTerm.toLowerCase();
      filteredItems = allItems.filter(function (item) {
        return (
          (item.name.includes(searchTermLower)) ||
          (item.description.includes(searchTermLower))// ||
          // (item.email.toLowerCase().includes(searchTermLower))// ||
          // (item.category.toLowerCase().includes(searchTermLower))
        );
      });
    }

    const pagesTotal = Math.floor(filteredItems.length / ENTRIES_PER_PAGE) + 1;
    const showItems = filteredItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

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
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td>
          <div>{item.name}</div>
          <div className="small text-muted">{item.description}</div>
        </td>
        <td className="text-center">{item.memberCount}</td>
        {/* <td>
          <div className="text-center">{item.phone}</div>
        </td>
        <td>
          <div className="text-center">
            {item.email}
          </div>
        </td> */}
      </tr>))

    return (
      <div className="card-container">
        <AssetCard
          sectionName={'Equipes'}
          sectionDescription={'Lista de equipes'}
          handleCardButton={this.handleURLChange}
          buttonName={'Cadastrar Equipe'}
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

export default withRouter(TeamsList);