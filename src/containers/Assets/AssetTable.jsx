import React, { Component } from 'react';
import { Row, Col, Button, FormGroup, InputGroup, InputGroupAddon, Input } from "reactstrap";
import AssetCard from "../../components/Cards/AssetCard";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");

class AssetTable extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <AssetCard
        sectionName={'Edifícios e áreas'}
        sectionDescription={'Endereçamento do Senado Federal'}
        handleCardButton={() => { }}
        buttonName={'Cadastrar Área'}
      >
        <Row style={{ marginTop: "10px" }}>
          <Col md="2">
            <Button
              color="dark"
              outline
              style={{ width: "35px", height: "35px", marginLeft: "10px", padding: "4px" }}
            >
              <img src={hierarchyItem} alt="" style={{ width: "100%", height: "100%" }} />
            </Button>
            <Button
              color="dark"
              outline
              style={{ width: "35px", height: "35px", marginLeft: "20px", padding: "4px" }}
            >
              <img src={listItem} alt="" style={{ width: "100%", height: "100%" }} />
            </Button>
          </Col>
          <Col md="4">
            <form>
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  borderColor: "#676767",
                  borderStyle: "solid",
                  borderRadius: "5px",
                  borderWidth: "1px",
                  width: "70%",
                  padding: " 1px 10px"
                }}
              >
                <img src={searchItem} alt="" style={{ width: "18px", height: "15px", margin: "3px 0px" }} />
                <input style={{ border: "none", marginRight: "15px", marginLeft: "5px", width: "100%" }} placeholder="Basic search ..." />
              </div>
            </form>
          </Col>
          <Col md="6"></Col>
        </Row>
      </AssetCard >
    );
  }
}

export default AssetTable;