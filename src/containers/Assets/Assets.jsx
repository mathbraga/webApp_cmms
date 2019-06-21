import React, { Component } from "react";
import FileInput from "../../components/FileInputs/FileInput";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import textToArrayFacility from "../../utils/assets/textToArrayFacility";
import buildFacilitiesParamsArr from "../../utils/assets/buildFacilitiesParamsArr";
import { connect } from "react-redux";
import getAllFacilities from "../../utils/assets/getAllFacilities";
import { dbTables } from "../../aws";

class Assets extends Component {
  constructor(props){
    super(props);
    this.state = {
      dbObject: initializeDynamoDB(this.props.session),
      tableName: dbTables.facility.tableName,
      assets: []
    }
  }

  componentDidMount = () => {
    getAllFacilities(this.state.dbObject, this.state.tableName)
    .then(assets => {
      this.setState({
        assets: assets
      });
      console.log(assets);
    })
    .catch(() =>{
      console.log("HOUVE UM PROBLEMA.")
    });
  }
  
  render(){
    return (
      <React.Fragment>
        <FileInput
            tableName={"Locais-SF"}
            dbObject={this.state.dbObject}
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