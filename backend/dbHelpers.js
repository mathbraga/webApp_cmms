// Check the following website:
// https://stackoverflow.com/questions/34382796/where-should-i-initialize-pg-promise
const db = require('./dbConnect');
const pgp = db.$config.pgp;

// ColumnSet definitions
// http://vitaly-t.github.io/pg-promise/helpers.ColumnSet.html
const cs1 = new pgp.helpers.ColumnSet([
  // '?id',
  {
    name: 'status1',
    def: ''
  },
  {
    name: 'prioridade',
    def: ''
  },
  {
    name: 'origem',
    def: ''
  },
  {
    name: 'responsavel',
    def: ''
  },
  {
    name: 'categoria',
    def: ''
  },
  {
    name: 'servico',
    def: ''
  },
  {
    name: 'descricao',
    def: ''
  },
  {
    name: 'data_inicial',
    def: ''
  },
  {
    name: 'data_prazo',
    def: ''
  },
  {
    name: 'realizado',
    def: 0
  },
  {
    name: 'data_criacao',
    def: ''
  },
  {
    name: 'data_atualiz',
    def: ''
  },
  {
    name: 'sigad',
    def: ''
  },
  {
    name: 'solic_orgao',
    def: ''
  },
  {
    name: 'solic_nome',
    def: ''
  },
  {
    name: 'contato_nome',
    def: ''
  },
  {
    name: 'contato_email',
    def: ''
  },
  {
    name: 'contato_tel',
    def: ''
  },
  {
    name: 'mensagem',
    def: ''
  },
  {
    name: 'orcamento',
    def: ''
  },
  {
    name: 'conferido',
    def: ''
  },
  {
    name: 'lugar',
    def: ''
  },
  {
    name: 'executante',
    def: ''
  },
  {
    name: 'os_num',
    def: ''
  },
  {
    name: 'ans',
    def: ''
  },
  {
    name: 'status2',
    def: ''
  },
  {
    name: 'multitarefa',
    def: ''
  }
], {table: {table: 'work_orders', schema: 'public'}});

const cs2 = new pgp.helpers.ColumnSet([
  {
    name: 'wo_id',
  },
  {
    name: 'asset_id'
  }
], {table: {table: 'wos_assets', schema: 'public'}});

module.exports = {
  cs1,
  cs2
};