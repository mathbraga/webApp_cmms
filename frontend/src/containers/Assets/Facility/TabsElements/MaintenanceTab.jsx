import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Description/DescriptionTable';
import { FormGroup, CustomInput } from 'reactstrap';

function itemsMatrixReport(data) {
  return (
    [
      [
        { id: 'unsettledMaintenance', title: 'Manutenções Pendentes', description: '0000', span: 1 },
        { id: 'prevent', title: 'Preventivas Agendadas', description: 'OS-0021 / OS-0025', line: 1, span: 1 },
      ],
      [
        { id: 'totalMaintenance', title: 'Manutenções Totais', description: '0000', span: 1 },
        { id: 'forAnaylsis', title: 'Requisições para Análise', description: 'RQ-0011 / RQ-0015', line: 1, span: 1 },
      ],
    ]
  );
}

function itemsMatrixMaintenance(data) {
  return (
    [
      [
        { id: 'parentAssets', title: 'Ativos Filhos Incluídos', description: 'Não', span: 1 },
        {
          id: 'includeAssets', elementGenerator: () =>
            (
              <FormGroup style={{ margin: "0" }}>
                <CustomInput disabled type="switch" id="child-assets" name="customSwitch" label="Incluir ativos filhos" />
              </FormGroup>
            ), line: 1, span: 1, style: { display: "flex", alignItems: "flex-end" }
        },
      ],
    ]
  );
}

class MaintenanceTab extends Component {
  render() {
    const { data } = this.props;
    return (
      <>
        <DescriptionTable
          title={'Relatório de Manutenções'}
          numColumns={2}
          itemsMatrix={itemsMatrixReport(data)}
        />
        <DescriptionTable
          title={'Tabela de Manutenções'}
          numColumns={2}
          itemsMatrix={itemsMatrixMaintenance(data)}
        />
        {/* <CardWithTable
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          data={data}
        /> */}
      </>
    );
  }
}

export default MaintenanceTab;