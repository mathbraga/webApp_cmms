import React, { Component } from 'react';
import "./Search.css";
import SearchInput from './SearchInput';
import {
  Button,
  Row,
  Col,
  Container
} from 'reactstrap';

const searchImage = require("../../assets/icons/search_icon.png");

export default class SearchContainer extends Component {
  render() {
    const {
      searchTerm,
      handleChangeSearchTerm,
      filterLogic,
      filterName,
      numberOfitems,
      toggleApply,
      toggleCreate
    } = this.props;

    return (
    <div>
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
            <li><span>Página com </span><b>{numberOfitems.toString()}</b><span> items</span></li>
          </ol>
        </div>
        <div className="search-buttons" style={{ width: "30%" }}>
          <Button name="modalApplyFilter" className="search-filter-button" color="success" onClick={toggleApply}>Aplicar Filtro</Button>
          <Button name="modalFilter" className="search-filter-button" color="primary" onClick={toggleCreate}>Criar Filtro</Button>
        </div>
      </div>

      {/*Testing new container */}
        <Row className="card-search-test">
        <div className="d-sm-block d-md-flex align-items-center">
          <Col sm="6" md="6" style={{ "padding-left": 0 }}>
            <SearchInput
              searchTerm={searchTerm}
              searchImage={searchImage}
              handleChangeSearchTerm={handleChangeSearchTerm}
            />
          </Col>
          {/* <div className="w-100 d-sm-block d-md-none"></div> */}
          <Col sm="3" md="4" className="search-filter">
            <ol>
              <li><span className="card-search-title">Filtro: </span></li>
              <li><span className="card-search-title">Resultado: </span></li>
            </ol>
            <ol>
              <li>{(filterLogic.length === 0) ? "Sem filtro" : (filterName || "Filtro sem nome")}</li>
              <li><span>Página com </span><b>{numberOfitems.toString()}</b><span> items</span></li>
            </ol>
          </Col>
        </div>
        <div className="d-sm-inline d-md-flex justify-content-center">
          <Col md="12" className="search-buttons">
            <Button name="modalApplyFilter" className="search-filter-button" color="success" onClick={toggleApply}>Aplicar Filtro</Button>
            <Button name="modalFilter" className="search-filter-button" color="primary" onClick={toggleCreate}>Criar Filtro</Button>
          </Col>
        </div>
        </Row>

    </div>
    );
  }
}