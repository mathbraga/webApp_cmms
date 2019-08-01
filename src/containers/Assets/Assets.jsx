import React, { Component } from "react";
import FileInput from "../../components/FileInputs/FileInput";
import FacilitiesList from "./FacilitiesList";
import EquipmentsList from "./EquipmentsList";
import AssetInfo from "./AssetInfo";
import { connect } from "react-redux";
import getAllAssets from "../../utils/assets/getAllAssets";
import { dbTables } from "../../aws";

import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";

import { locationItems, equipmentItems } from "./AssetsFakeData";
import { Switch, Route } from "react-router-dom";

class Assets extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tableName: dbTables.asset.tableName,
      dbObject: initializeDynamoDB(this.props.session)
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
      <AssetInfo />
      // <Switch>
      //   <Route path="/ativos/edificios" render={routeProps => <FacilitiesList />} />
      //   <Route path="/ativos/equipamentos" render={routeProps => <EquipmentsList />} />
      // </Switch>
    )
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(Assets);