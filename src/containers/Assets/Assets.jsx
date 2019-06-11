import React, { Component } from "react";
import FileInput from "../../components/FileInputs/FileInput";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import buildFacilitiesParamsArr from "../../utils/assets/buildFacilitiesParamsArr";
import { connect } from "react-redux";

class Assets extends Component {
  render(){
    return (
      <React.Fragment>
        <FileInput
            tableName={"Locais-SF"}
            dbObject={initializeDynamoDB(this.props.session)}
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