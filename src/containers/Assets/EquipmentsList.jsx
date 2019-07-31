import React, { Component } from 'react';
import { Row, Col, Button, } from "reactstrap";
import TableItems from "../../components/Tables/Table";
import AssetCard from "../../components/Cards/AssetCard";
import { Badge, CustomInput } from "reactstrap";
import "./List.css";
import { remove } from "lodash";
import { withRouter } from "react-router-dom";

import { /*equipmentItems,*/ equipmentConfig } from "./AssetsFakeData";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

const mapIcon = require("../../assets/icons/map.png");
const headerConfig = equipmentConfig;



class FacilitiesList extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {

    const {
      allItems
    } = this.props;

    const equipmentItems = remove(allItems, item => {
      return item.tipo === 'E';
    });


    const Thead =
  <tr>
    <th className="text-center checkbox-cell">
      <CustomInput type="checkbox" />
    </th>
    {headerConfig.map(column => (
      <th style={column.style} className={column.className}>{column.description}</th>))
    }
  </tr>

const Tbody = equipmentItems.map(item => (
  <tr
    onClick={()=>{this.props.history.push('/ativos/view/' + item.id)}}
  >
    <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
    <td>
      <div>{item.modelo}</div>
      <div className="small text-muted">{item.parent}</div>
    </td>
    <td className="text-center">Marca</td>
    <td className="text-center">Modelo</td>
    <td>
      <div className="text-center">
        Categoria
      </div>
    </td>
  </tr>))

    return (
      <AssetCard
        sectionName={'Equipamentos'}
        sectionDescription={'Lista de equipamentos de engeharia'}
        handleCardButton={() => { }}
        buttonName={'Cadastrar Equipamento'}
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
            <div style={{ display: "flex", justifyContent: "flex-end", paddingRight: "10px", margin: "5px 5px" }}>Página 1 de 1</div>
          </Col>
        </Row>
        <Row>
          <Col>
            <TableItems
              thead={Thead}
              tbody={Tbody}
            />
          </Col>
        </Row>
      </AssetCard >
    );
  }
}

export default withRouter(FacilitiesList);