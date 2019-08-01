import React, { Component } from 'react';
import { Row, Col, Button, } from "reactstrap";
import TableWithPages from "../../components/Tables/TableWithPages";
import AssetCard from "../../components/Cards/AssetCard";
import { Badge, CustomInput } from "reactstrap";
import { remove } from "lodash";
import { withRouter } from "react-router-dom";
import "./List.css";

import { locationConfig } from "./AssetsFakeData";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

const mapIcon = require("../../assets/icons/map.png");



class FacilitiesList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      pagesTotal: 1,
      pageCurrent: 1
    };

    this.setCurrentPage = this.setCurrentPage.bind(this);
  }

  setCurrentPage(pageCurrent) {
    this.setState({ pageCurrent: pageCurrent });
  }

  render() {
    const { allItems } = this.props;
    const { pageCurrent } = this.state;
    const pagesTotal = allItems.length;
    const locationItems = allItems.slice(0, 15)

    const thead =
      <tr>
        <th className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </th>
        {locationConfig.map(column => (
          <th style={column.style} className={column.className}>{column.description}</th>))
        }
      </tr>

    const tbody = locationItems.map(item => (
      <tr
        onClick={() => { this.props.history.push('/ativos/view/' + item.id) }}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td>
          <div>{item.nome + " - " + item.subnome}</div>
          <div className="small text-muted">{item.parent}</div>
        </td>
        <td className="text-center">{item.id}</td>
        <td className="text-center">
          <Badge className="mr-1" color={item.visita ? "success" : "danger"} style={{ width: "60px", color: "black" }}>{item.visita ? "Sim" : "Não"}</Badge>
        </td>
        <td>
          <div className="text-center">{item.areaconst}</div>
        </td>
        <td>
          <div className="text-center">
            <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
          </div>
        </td>
        <td>
          <div className="text-center">
            {item.list_wos.map(wo => (
              <p>{wo.toString()}<br /></p>
            ))}
          </div>
        </td>
      </tr>))

    return (
      <AssetCard
        sectionName={'Edifícios e áreas'}
        sectionDescription={'Endereçamento do Senado Federal'}
        handleCardButton={() => { }}
        buttonName={'Cadastrar Área'}
      >
        <Row style={{ marginTop: "10px", marginBottom: "5px" }}>
          <Col md="2">
            <Button
              color="dark"
              className="button-inside"
              outline
              style={{ marginLeft: "10px" }}
            >
              <img src={hierarchyItem} alt="" style={{ width: "100%", height: "100%" }} />
            </Button>
            <Button
              color="dark"
              className="button-inside"
              outline
              style={{ marginLeft: "20px" }}
            >
              <img src={listItem} alt="" style={{ width: "100%", height: "100%" }} />
            </Button>
          </Col>
          <Col md="4">
            <form>
              <div className="search-input" >
                <input placeholder="Pesquisar ..." />
                <img src={searchItem} alt="" style={{ width: "18px", height: "15px", margin: "3px 0px" }} />
              </div>
            </form>
            <div style={{ color: "blue", textDecoration: "underline", marginLeft: "10px", fontSize: "12.4px" }}>
              Pesquisa Avançada
            </div>
          </Col>
          <Col md="6">
          </Col>
        </Row>
        <Row>
          <Col>
            <TableWithPages
              thead={thead}
              tbody={tbody}
              pagesTotal={pagesTotal}
              pageCurrent={pageCurrent}
              setCurrentPage={this.setCurrentPage}
            />
          </Col>
        </Row>
      </AssetCard >
    );
  }
}

export default withRouter(FacilitiesList);