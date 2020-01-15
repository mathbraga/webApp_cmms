import React, { Component } from 'react';
import Search from './Search';

const filterAttributes = {
  assetSf: { name: 'Código', type: 'text' },
  manufacturer: { name: 'Fabricante', type: 'text' },
  model: { name: 'Modelo', type: 'text' },
  name: { name: 'Nome', type: 'text' },
  serialnum: { name: 'Número serial', type: 'text' },
};

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

export default class SearchWithFilter extends Component {
  constructor(props) {
    super(props);
    this.state = {
      modalFilter: false,
      modalApplyFilter: false
    }

    this.toggleFilter = this.toggleFilter.bind(this);
  }

  toggleFilter(e) {
    console.log(e);
  }

  render() {
    const {
      updateCurrentFilter,
      filterSavedId,
      searchTerm,
      handleChangeSearchTerm,
      filterLogic,
      filterName,
      numberOfItens,
    } = this.props;
    return (
      <>
        <Search
          searchTerm={searchTerm}
          handleChangeSearchTerm={handleChangeSearchTerm}
          filterLogic={filterLogic}
          filterName={filterName}
          numberOfItens={numberOfItens}
          toggleApply={this.toggleFilter}
          toggleCreate={this.toggleFilter}
        />
        <ModalCreateFilter
          toggle={this.toggleFilter}
          modal={this.state.modalFilter}
          attributes={filterAttributes}
          updateCurrentFilter={updateCurrentFilter}
        />
        <ApplyFilter
          toggle={this.toggleFilter}
          modal={this.state.modalApplyFilter}
          attributes={filterAttributes}
          updateCurrentFilter={updateCurrentFilter}
          customFilters={customFilters}
          currentFilterId={filterSavedId}
        />
      </>
    );
  }
}