import React, { Component } from "react";
import FileInput from "../../components/FileInputs/FileInput";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import textToArrayFacility from "../../utils/assets/textToArrayFacility";
import buildFacilitiesParamsArr from "../../utils/assets/buildFacilitiesParamsArr";
import AssetTable from "./AssetTable";
import { connect } from "react-redux";

class Assets extends Component {
  render() {
    return (
      <React.Fragment>
        <AssetTable />
        <FileInput
          tableName={"Locais-SF"}
          dbObject={initializeDynamoDB(this.props.session)}
          readFile={textToArrayFacility}
          buildParamsArr={buildFacilitiesParamsArr}
        />
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