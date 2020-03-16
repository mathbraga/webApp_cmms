import React, { Component } from 'react';
import SvgTest from '../../assets/mapsSvg/Test';
import './Maps.css';

class Maps extends Component {
  state = {  }
  render() { 
    return ( 
      <div
        className="map-container"
      >
        <SvgTest 
          handleArea={(event) => {console.log("Event: ", event.target.id)}} 
          handleMouseEnter={(event) => {console.log("Enter: ", event.target.id)}} 
          handleMouseLeave={(event) => {console.log("Leave: ", event.target.id)}}
        />
      </div>
    );
  }
}
 
export default Maps;