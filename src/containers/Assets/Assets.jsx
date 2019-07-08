import React, { Component } from "react";
import AssetTable from "./AssetTable";
import { connect } from "react-redux";
import getAllAssets from "../../utils/assets/getAllAssets";
import { dbTables } from "../../aws";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import { allAssets } from "../Maintenance/allAssets";
import FileInput from "../../components/FileInputs/FileInput";
import { sortBy } from "lodash";

class Assets extends Component {
  constructor(props){
    super(props);
    this.state = {
      tableName: dbTables.asset.tableName,
      dbObject: initializeDynamoDB(this.props.session)
    }
  }

  componentDidMount(){
    console.log("Assets list from file:");
    console.log(sortBy(allAssets, "id"));
    getAllAssets(this.state.dbObject, this.state.tableName)
    .then(assets => {
      console.log("Assets list from database:");
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
      <React.Fragment>
        <FileInput
          readFile={dbTables.asset.readFile}
          tableName={dbTables.asset.tableName}
          dbObject={this.state.dbObject}
          buildParamsArr={dbTables.asset.buildParamsArr}
        />
        <AssetTable />
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