import React, { Component } from 'react';
import "./AssetInfo.css";
import { connect } from "react-redux";

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

import EquipmentInfo from './EquipmentInfo';
import FacilitiesInfo from './FacilitiesInfo';

class AssetInfo extends Component {

  render() {
    const assetSf = this.props.location.pathname.slice(13);
    const assetInfoQuery = gql`
      query ($assetSf: String!) {
        assetByAssetSf(assetSf: $assetSf) {
          area
          assetSf
          category
          description
          latitude
          longitude
          manufacturer
          model
          name
          nodeId
          orderAssetsByAssetId {
            nodes {
              orderByOrderId {
                category
                description
                dateLimit
                createdBy
                createdAt
                priority
                orderId
                status
                title
              }
            }
          }
        }
      }
    `;
    return (
      <Query
        query={assetInfoQuery}
        variables={{ assetSf: assetSf }}
      >
        {
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              return null
            }

            const { category } = data.assetByAssetSf;

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