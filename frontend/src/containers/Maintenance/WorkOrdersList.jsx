import React, { Component } from 'react';
import { Row, Col, Button, } from "reactstrap";
import TableWithPages from "../../components/Tables/TableWithPages";
import AssetCard from "../../components/Cards/AssetCard";
import { Badge, CustomInput } from "reactstrap";
import { remove } from "lodash";
import { withRouter } from "react-router-dom";
import "./List.css";

import { tableConfig } from "./WorkOrdersTableConfig";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

const mapIcon = require("../../assets/icons/map.png");



class WorkOrdersList extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {

    const {
      allItems
    } = this.props;

    const Thead =
    <tr>
      <th className="text-center checkbox-cell">
        <CustomInput type="checkbox" />
      </th>
      {tableConfig.map(column => (
        <th style={column.style} className="text-center">{column.name}</th>))
      }
    </tr>

    const Tbody = allItems.map(item => (
      <tr
        onClick={()=>{this.props.history.push('/manutencao/os/view/' + item.id)}}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td>
          <div>{item.id}</div>
          <div className="small text-muted">{item.categoria}</div>
        </td>
        <td className="text-center">{item.descricao}</td>
        <td className="text-center">{item.status1}</td>
        <td>
          <div className="text-center">{item.data_criacao}</div>
        </td>
        <td>
          <div className="text-center">{item.data_prazo}</div>
        </td>
        <td>
          <div className="text-center">{item.solic_nome}</div>
        </td>
        <td>
          {item.list_assets.map(asset => (
            <div className="text-center">{asset}</div>
          ))}
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
              thead={Thead}
              tbody={Tbody}
            />
          </Col>
        </Row>
      </AssetCard >
    );
  }
}

export default withRouter(WorkOrdersList);