import React, { Component } from "react";
import FacilitiesList from "./FacilitiesList";
import EquipmentsList from "./EquipmentsList";
import AssetInfo from "./AssetInfo";
import { connect } from "react-redux";
import getAllAssets from "../../utils/assets/getAllAssets";
import { dbTables } from "../../aws";

import { locationItems, equipmentItems } from "./AssetsFakeData";
import { Switch, Route } from "react-router-dom";

class Assets extends Component {
  constructor(props) {
    super(props);
    this.state = {
      assets: []
    }
  }

  componentDidMount() {
    getAllAssets()
      .then(assets => {
        console.log("List of all assets from database:");
        console.log(assets);
        this.setState({
          assets: assets
        });
      })
      .catch(() => {
        console.log('houve um erro ao baixar os ativos!');
      })
  }

  render() {



    return (
<<<<<<< HEAD:frontend/src/containers/Assets/Assets.jsx
      <React.Fragment>
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
||||||| merged common ancestors
      <FacilitiesList />
      // <Switch>
      //   <Route path="/ativos/edificios" render={routeProps => <FacilitiesList />} />
      //   <Route path="/ativos/equipamentos" render={routeProps => <EquipmentsList />} />
      // </Switch>
=======
      <AssetInfo />
      // <Switch>
      //   <Route path="/ativos/edificios" render={routeProps => <FacilitiesList />} />
      //   <Route path="/ativos/equipamentos" render={routeProps => <EquipmentsList />} />
      // </Switch>
>>>>>>> c1d209876e0539d5fb76afa80d4b313a7a184c1f:src/containers/Assets/Assets.jsx
    )
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(Assets);