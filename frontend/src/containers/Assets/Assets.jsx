import React, { Component } from "react";
import FacilitiesList from "./FacilitiesList";
import EquipmentsList from "./EquipmentsList";
import AssetInfo from "./AssetInfo";
import { connect } from "react-redux";
import getAllAssets from "../../utils/assets/getAllAssets";
import { remove } from "lodash";
import { dbTables } from "../../aws";
import fetchDB from "../../utils/fetch/fetchDB";

import { locationItems, equipmentItems } from "./AssetsFakeData";
import { Switch, Route } from "react-router-dom";

class Assets extends Component {
  constructor(props) {
    super(props);
    this.state = {
      assets: []
    };
    this.handleAssetsChange = this.handleAssetsChange.bind(this);
  }

  handleAssetsChange(dbResponse){
    this.setState({ assets: dbResponse });
  }

  componentDidMount() {
    const tipo = this.props.location.pathname.slice(8) === "edificios" ? "A" : "E";
    fetchDB({
      query: `
      query Query1($tipo: String!) {
        allAssets(condition: {tipo: $tipo}, orderBy: ID_ASC) {
          edges {
            node {
              tipo
              id
              nome
              subnome
              assetsParentsById(orderBy: ID_ASC) {
                nodes {
                  parent
                }
              }
            }
          }
        }
      }
    `,
    variables: {tipo: tipo}
  })
      .then(r => r.json())
      .then(rjson => this.handleAssetsChange(rjson))
      .catch(()=>console.log('Houve um erro ao baixar os ativos!'));
  }

  render() {
    return (
      <React.Fragment>
        {console.clear()}
        {console.log(this.state.assets)}
        {(this.state.assets.length !== 0 && this.props.location.pathname.slice(8) === "edificios") &&
          <FacilitiesList
            allItems={this.state.assets}
          />
        }
        {(this.state.assets.length !== 0 && this.props.location.pathname.slice(8) === "equipamentos") &&
          <EquipmentsList
            allItems={this.state.assets}
          />
        }
        {/* <Switch>
          <Route path="/ativos/edificios" render={routeProps => <FacilitiesList />} />
          <Route path="/ativos/equipamentos" render={routeProps => <EquipmentsList />} />
        </Switch> */}
      </React.Fragment>
    )
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(Assets);