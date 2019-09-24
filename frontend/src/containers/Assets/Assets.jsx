import React, { Component } from "react";
import FacilitiesList from "./FacilitiesList";
import EquipmentsList from "./EquipmentsList";
import AssetInfo from "./AssetInfo";
import { connect } from "react-redux";
import getAllAssets from "../../utils/assets/getAllAssets";
import { remove } from "lodash";
import { dbTables } from "../../aws";
import fetchDB from "../../utils/fetch/fetchDB";

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

import { locationItems, equipmentItems } from "./AssetsFakeData";
import { Switch, Route } from "react-router-dom";

class Assets extends Component {
  render() {
    console.log(this.props)
    const category = this.props.location.pathname.slice(8) === "edificios" ? "F" : "A";
    const fetchAssets = gql`
      query assetsQuery($category: AssetCategoryType!) {
        allAssets(condition: {category: $category}, orderBy: ASSET_ID_ASC) {
          edges {
            node {
              parent
              name
              model
              manufacturer
              assetId
              category
              serialnum
              area
              assetByPlace {
                assetId
                name
              }
              assetByParent {
                name
                assetId
              }
            }
          }
        }
      }`;
    return (
      <Query
        query={fetchAssets}
        variables={{ category: category }}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              console.log("Erro ao tentar baixar os ativos!");
              return null
            }
            const assets = data;

            return (
              <React.Fragment>
                {(assets.allAssets.edges.length !== 0 && this.props.location.pathname.slice(8) === "edificios") &&
                  <FacilitiesList
                    allItems={assets}
                  />
                }
                {(assets.allAssets.edges.length !== 0 && this.props.location.pathname.slice(8) === "equipamentos") &&
                  <EquipmentsList
                    allItems={assets}
                  />
                }
              </React.Fragment>
            )
          }
        }</Query>
    )
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(Assets);