import React, { Component } from 'react';
import { Badge, CustomInput } from "reactstrap";
import "./Table.css";

const mapIcon = require("../../assets/icons/map.png");

class TableItems extends Component {
  render() {
    const { tableConfig, items } = this.props;
    return (<div className="table-scroll">
      <table className="content-table">
        <thead className="thead-light">
          <tr>
            <th className="text-center checkbox-cell">
              <CustomInput type="checkbox" />
            </th>
            {tableConfig.map(column => (
              <th style={column.style} className={column.className}>{column.name}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {items.map(item => (
            <tr>
              <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
              <td>
                <div>{item.location}</div>
                <div className="small text-muted">{item.parent}</div>
              </td>
              <td className="text-center">{item.code}</td>
              <td className="text-center">
                <Badge className="mr-1" color={item.visiting === "sim" ? "success" : "warning"} style={{ width: "60px", color: "black" }}>{item.visiting}</Badge>
              </td>
              <td>
                <div className="text-center">{item.area}</div>
              </td>
              <td>
                <div className="text-center">
                  <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>);
  }
}

export default TableItems;