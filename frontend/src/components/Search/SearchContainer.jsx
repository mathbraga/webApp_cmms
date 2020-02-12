import React, { Component } from 'react';
import "./Search.css";
import SearchInput from './SearchInput';
import {
  Button
} from 'reactstrap';

const searchImage = require("../../assets/icons/search_icon.png");

export default class SearchContainer extends Component {
  render() {
    const {
      searchTerm,
      handleChangeSearchTerm,
      filterLogic,
      filterName,
      numberOfItens,
      toggleApply,
      toggleCreate
    } = this.props;

    return (
      <div className="card-search-container">
        <SearchInput
          searchTerm={searchTerm}
          searchImage={searchImage}
          handleChangeSearchTerm={handleChangeSearchTerm}
        />
        <div className="search-filter" style={{ width: "30%" }}>
          <ol>
            <li><span className="card-search-title">Filtro: </span></li>
            <li><span className="card-search-title">Resultado: </span></li>
          </ol>
          <ol>
            <li>{(filterLogic.length === 0) ? "Sem filtro" : (filterName || "Filtro sem nome")}</li>
            <li><span>Página com </span><b>{numberOfItens.toString()}</b><span> itens</span></li>
          </ol>
        </div>
        <div className="search-buttons" style={{ width: "30%" }}>
          <Button name="modalApplyFilter" className="search-filter-button" color="success" onClick={toggleApply}>Aplicar Filtro</Button>
          <Button name="modalFilter" className="search-filter-button" color="primary" onClick={toggleCreate}>Criar Filtro</Button>
        </div>
      </div>
    );
  }
}