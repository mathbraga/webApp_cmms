import React, { Component } from "react";
import AssetTable from "./AssetTable";
import { connect } from "react-redux";
import getAllAssets from "../../utils/assets/getAllAssets";
import { dbTables } from "../../aws";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";


class Assets extends Component {
  constructor(props){
    super(props);
    this.state = {
      tableName: dbTables.asset.tableName,
      dbObject: initializeDynamoDB(this.props.session)
    }
  }

  componentDidMount(){
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
      <React.Fragment>
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