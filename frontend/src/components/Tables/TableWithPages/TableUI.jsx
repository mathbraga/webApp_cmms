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
    data.map((item) => {
      let correctPath = item.categoryId === 1 ? '/ativos/edificio/view/' : '/ativos/equipamento/view/';
      return(
      <tr
        onClick={tableConfig.itemClickable && (
          () => {
            history.push(tableConfig.isTableMixed ? (correctPath + item[tableConfig.idAttributeForData]) : 
              tableConfig.itemPath + item[tableConfig.idAttributeForData])
          })}
      >
        <td className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </td>

        {tableConfig.columnObjects.map((column) => {
          let dataWrapper = function (item) { return column.data.map((ID) => (item[ID])); };
          if (column.dataGenerator) {
            dataWrapper = column.dataGenerator;
          }

          if (column.createElement) {
            return (
              <td className={column.className}>{column.createElement}</td>
            );
          }

          const itemToDisplay = dataWrapper(item);

          if (column.data.length >= 2) {
            return (
              <td className={column.className}>
                <div>{itemToDisplay[0]}</div>
                <div className="small text-muted" >{itemToDisplay[1]}</div>
              </td>
            );
          }

          return (<td className={column.className}>{itemToDisplay[0]}</td>);
        })
        }
      </tr>
      )
    })
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