import React, { Component } from "react";
import FileInput from "../../components/FileInputs/FileInput";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import textToArrayFacility from "../../utils/assets/textToArrayFacility";
import buildFacilitiesParamsArr from "../../utils/assets/buildFacilitiesParamsArr";
import AssetTable from "./AssetTable";
import { connect } from "react-redux";
import getAllFacilities from "../../utils/assets/getAllFacilities";
import { dbTables } from "../../aws";

class Assets extends Component {
  render() {
    return (
      <AssetTable />
    )
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(Assets);