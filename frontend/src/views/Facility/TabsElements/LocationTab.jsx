import React, { Component } from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import './Tabs.css';

class LocationTab extends Component {
  state = {}
  render() {
    return (
      <>
        <DescriptionTable
          title={'Planta Arquitetônica'}
        />
        <div className="asset-info-content">
          <div className="asset-info-map"></div>
        </div>
      </>
    );
  }
}

export default LocationTab;