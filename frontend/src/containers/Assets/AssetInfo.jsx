import React, { Component } from 'react';
import "./AssetInfo.css";
import { connect } from "react-redux";

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

import EquipmentInfo from './EquipmentInfo';
import FacilitiesInfo from './FacilitiesInfo';


class AssetInfo extends Component {

  render() {
    const assetId = this.props.location.pathname.slice(13);
    const assetInfoQuery = gql`
      query ($assetId: String!) {
        assetByAssetId(assetId: $assetId) {
          category
          assetId
          model
          area
          description
          latitude
          longitude
          manufacturer
          name
          nodeId
          parent
          place
          price
          serialnum
          warranty
          assetByParent {
            assetId
            name
          }
          orderAssetsByAssetId(condition: {assetId: $assetId}, orderBy: ASSET_ID_ASC) {
            edges {
              node {
                assetId
                orderId
                orderByOrderId {
                  orderId
                  requestText
                  status
                  requestPerson
                  createdAt
                  dateLimit
                  requestTitle
                  requestLocal
                  priority
                }
              }
            }
          }
          assetDepartmentsByAssetId {
            edges {
              node {
                departmentByDepartmentId {
                  fullName
                  departmentId
                }
              }
            }
          }
        }
      }
    `;
    return (
      <Query
        query={assetInfoQuery}
        variables={{ assetId: assetId }}
      >
        {
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              console.log("Erro ao tentar baixar os ativos!");
              return null
            }

            const { category } = data.assetByAssetId;

            if (category === 'A') {
              return <EquipmentInfo data={data} />;
            } else if (category === 'F') {
              return <FacilitiesInfo data={data} />;
            }
          }
        }
      </Query>
    );
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(AssetInfo);