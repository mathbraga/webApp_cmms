import React, { Component } from "react";
import FileInput from "../../components/FileInputs/FileInput";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import textToArrayFacility from "../../utils/assets/textToArrayFacility";
import buildFacilitiesParamsArr from "../../utils/assets/buildFacilitiesParamsArr";
import EquipmentList from "./EquipmentList";
import { connect } from "react-redux";
import getAllFacilities from "../../utils/assets/getAllFacilities";
import { dbTables } from "../../aws";
import { locationItems, equipmentItems } from "./AssetsFakeData";
import { Switch, Route } from "react-router-dom";

class Assets extends Component {
  render() {
    return (
      <Switch>
        <Route path="/ativos/todos" render={routeProps => <React.Fragment />} />
        <Route path="/ativos/edificios" render={routeProps => <EquipmentList />} />
        <Route path="/ativos/equipamentos" render={routeProps => <React.Fragment />} />
      </Switch>
    )
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(Assets);