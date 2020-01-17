import React from 'react';
import { CustomInput } from 'reactstrap';
import TableWithPages from './TableWithPages';
import { withRouter } from "react-router-dom";

function TableHeader({ tableConfig }) {
  return (
    <tr>
      <th className="text-center checkbox-cell">
        <CustomInput type="checkbox" />
      </th>
      {tableConfig.columnObjects.map((column) => (
        <th style={column.style} className={column.className}>{column.description}</th>
      ))}
    </tr>
  );
};

function TableBody({ tableConfig, data, history }) {
  return (
    data.map((item) => (
      <tr
        onClick={() => { history.push(tableConfig.itemPath + item[tableConfig.idAttributeForData]) }}
      >
        <td className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </td>
        
        {tableConfig.columnObjects.map((column) => {
            if (column.createElement) {
              return (
              <td className={column.className}>{column.createElement}</td>
              );
            }

            if (column.data.length >= 2) {
              return (
                <td className={column.className}>
                  <div>{item[column.data[0]]}</div>
                  <div className="small text-muted" >{item[column.data[1]]}</div>
                </td>
              );
            }
            
            return (<td className={column.className}>{item[column.name]}</td>);
          })
        }
      </tr>
    ))
  );
}

function FinalTableUI({ tableConfig, data, history, ...rest }) {
  return (
    <TableWithPages
      thead={<TableHeader tableConfig={tableConfig} />}
      tbody={<TableBody data={data} tableConfig={tableConfig} history={history} />}
      {...rest}
    />
  );
}

export default withRouter(FinalTableUI);