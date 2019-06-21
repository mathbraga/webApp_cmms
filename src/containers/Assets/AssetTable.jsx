import React, { Component } from 'react';
import { Row, Col, Button, FormGroup, InputGroup, InputGroupAddon, Input, Table, Progress, Badge, CustomInput } from "reactstrap";
import AssetCard from "../../components/Cards/AssetCard";
import "./AssetTable.css";

const hierarchyItem = require("../../assets/icons/tree_icon.png");
const listItem = require("../../assets/icons/list_icon.png");
const searchItem = require("../../assets/icons/search_icon.png");
const mapIcon = require("../../assets/icons/map.png");

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
        <Row style={{ marginTop: "10px", marginBottom: "20px" }}>
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
                <input style={{ border: "none", marginRight: "15px", marginLeft: "5px", width: "100%" }} placeholder="Pesquisar ..." />
              </div>
            </form>
            <div style={{ color: "blue", textDecoration: "underline", marginLeft: "5px" }}>
              Pesquisa Avançada
            </div>
            {/* <InputGroup>
              <Input placeholder="username" />
              <InputGroupAddon addonType="append">@example.com</InputGroupAddon>
            </InputGroup> */}
          </Col>
          <Col md="6">
          </Col>
        </Row>
        <Row>
          <Col>
            <Table
              hover responsive className="table-outline mb-0 d-none d-sm-table table-card" >
              <thead className="thead-light">
                <tr>
                  <th className="text-center checkbox-cell">
                    <CustomInput type="checkbox" />
                  </th>
                  <th className="location-cell">Localização</th>
                  <th className="text-center category-cell">Código</th>
                  <th className="text-center visit-cell">Visitação</th>
                  <th className="text-center visit-cell">Área</th>
                  <th className="text-center">Mapa</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Edíficio Principal</div>
                    <div className="small text-muted">
                      Complexo Arquitetônico do Senado Federal
                    </div>
                  </td>
                  <td className="text-center">
                    EDP-ANX-000
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="success" style={{ width: "60px", color: "black" }}>Sim</Badge>
                  </td>
                  <td>
                    <div className="text-center">1.200 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Gabinete do Senador José Serra</div>
                    <div className="small text-muted">
                      Edifício Anexo I
                    </div>
                  </td>
                  <td className="text-center">
                    GBN-ANX-025
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="warning" style={{ width: "60px", color: "black" }}>Não</Badge>
                  </td>
                  <td>
                    <div className="text-center">100 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Diretoria da Sinfra</div>
                    <div className="small text-muted">
                      Bloco 14 - Gráfica
                    </div>
                  </td>
                  <td className="text-center">
                    DIR-BOH-030
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="warning" style={{ width: "60px", color: "black" }}>Não</Badge>
                  </td>
                  <td>
                    <div className="text-center">70 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </ tr>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Edíficio Principal</div>
                    <div className="small text-muted">
                      Complexo Arquitetônico do Senado Federal
                    </div>
                  </td>
                  <td className="text-center">
                    EDP-ANX-000
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="success" style={{ width: "60px", color: "black" }}>Sim</Badge>
                  </td>
                  <td>
                    <div className="text-center">1.200 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Gabinete do Senador José Serra</div>
                    <div className="small text-muted">
                      Edifício Anexo I
                    </div>
                  </td>
                  <td className="text-center">
                    GBN-ANX-025
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="warning" style={{ width: "60px", color: "black" }}>Não</Badge>
                  </td>
                  <td>
                    <div className="text-center">100 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Diretoria da Sinfra</div>
                    <div className="small text-muted">
                      Bloco 14 - Gráfica
                    </div>
                  </td>
                  <td className="text-center">
                    DIR-BOH-030
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="warning" style={{ width: "60px", color: "black" }}>Não</Badge>
                  </td>
                  <td>
                    <div className="text-center">70 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </ tr>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Edíficio Principal</div>
                    <div className="small text-muted">
                      Complexo Arquitetônico do Senado Federal
                    </div>
                  </td>
                  <td className="text-center">
                    EDP-ANX-000
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="success" style={{ width: "60px", color: "black" }}>Sim</Badge>
                  </td>
                  <td>
                    <div className="text-center">1.200 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Gabinete do Senador José Serra</div>
                    <div className="small text-muted">
                      Edifício Anexo I
                    </div>
                  </td>
                  <td className="text-center">
                    GBN-ANX-025
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="warning" style={{ width: "60px", color: "black" }}>Não</Badge>
                  </td>
                  <td>
                    <div className="text-center">100 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><CustomInput type="checkbox" /></td>
                  <td>
                    <div>Diretoria da Sinfra</div>
                    <div className="small text-muted">
                      Bloco 14 - Gráfica
                    </div>
                  </td>
                  <td className="text-center">
                    DIR-BOH-030
                  </td>
                  <td className="text-center">
                    <Badge className="mr-1" color="warning" style={{ width: "60px", color: "black" }}>Não</Badge>
                  </td>
                  <td>
                    <div className="text-center">70 m²</div>
                  </td>
                  <td>
                    <div className="text-center">
                      <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                    </div>
                  </td>
                </ tr>
              </tbody>
            </Table>
          </Col>
        </Row>
      </AssetCard >
    );
  }
}

export default AssetTable;