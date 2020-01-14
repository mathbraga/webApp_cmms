import React, { Component } from "react";
import FacilitiesList from "./FacilitiesList";
import EquipmentsList from "./EquipmentsList";
import { connect } from "react-redux";
import fetchAssetsString from './dataFetchingStrings';

import { Query } from 'react-apollo';

class Assets extends Component {
  render() {
    const category = this.props.location.pathname.slice(8) === "edificios" ? "F" : "A";
    return (
      <Query
        query={fetchAssetsString}
        variables={{ category: category }}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
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
        }
      </Query>
    )
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(Assets);