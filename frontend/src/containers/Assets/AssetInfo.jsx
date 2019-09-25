import React, { Component } from 'react';
import "./AssetInfo.css";
import { connect } from "react-redux";

import { Query } from 'react-apollo';
import gql from 'graphql-tag';


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
            const { category } = data.assetByAssetId;
            if (loading) return null
            if (error) {
              console.log("Erro ao tentar baixar os ativos!");
              return null
            }
            if (category === 'F') {
              return <div>Facilities</div>;
            } else if (category === 'E') {
              return <div>Equipment</div>;
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