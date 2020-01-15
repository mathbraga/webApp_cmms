import React, { Component } from 'react';
import { CustomInput } from 'reactstrap';

const testTableConfig = {
  numberOfColumns: 10,
  checkbox: true,
  columnObjects: [
    { name: '1', description: 'a', className: 'b', style: 'c', data: ['id1', 'id2']},
    { name: '2', description: 'd', className: 'b', style: 'c', data: ['id3']},
  ],
};

function TableHeader({ tableConfig }) {
  return (
    <tr>
      <th className="text-center checkbox-cell">
        <CustomInput type="checkbox" />
      </th>
      {tableConfig.columnObjects.map((column) => (
        <th style={column.style} className={column.className}>column.description</th>
      ))}
    </tr>
  );
};

function TableBody({ tableConfig, data }) {
  return (
    data.map((item) => (
      <tr>
        <td className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </td>
        {tableConfig.columnObjects.map((column) => (
          column.data.length >= 2 
          ? <td>
              <div>{item[column.data[0]]}</div>
              <div className="small text-muted" >{item[column.data[1]]}</div>
            </td>
          : <td className="text-center">{item[column.name]}</td>
        ))}
      </tr>
    ))
  );
}

function createTableWithPages({ tableConfig, data }) {
  return (

  );
}