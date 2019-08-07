const express = require('express');
const router = express.Router();
const db = require('../dbConnect');
const cs = require('../dbHelpers');
const cs1 = cs.cs1;
const cs2 = cs.cs2;

// GET routes
router.get('/', (req, res) => {
  db.any('SELECT * FROM get_all_work_orders()')
  .then(data => {
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na route /manutencao/os"});
  });
});

router.get('/view', (req, res) => {
  console.log('\nreq.query:')
  console.log(req.query);
  db.one("SELECT * FROM get_work_order($1)", [req.query.id])
  .then(data => {
    console.log('\nwork order:');
    console.log(data);
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na route /manutencao/os/view"});
  });
});


// POST routes
router.post("/nova", function(req, res){
  let data1 = [{
    status1: req.body.status1,
    prioridade: req.body.prioridade,
    origem: req.body.origem,
    responsavel: req.body.responsavel,
    categoria: req.body.categoria,
    servico: req.body.servico,
    descricao: req.body.descricao,
    data_inicial: req.body.data_inicial,
    data_prazo: req.body.data_prazo,
    realizado: req.body.realizado,
    data_criacao: req.body.data_criacao,
    data_atualiz: req.body.data_atualiz,
    sigad: req.body.sigad,
    solic_orgao: req.body.solic_orgao,
    solic_nome: req.body.solic_nome,
    contato_nome: req.body.contato_nome,
    contato_email: req.body.contato_email,
    contato_tel: req.body.contato_tel,
    mensagem: req.body.mensagem,
    orcamento: req.body.orcamento,
    conferido: req.body.conferido,
    lugar: req.body.lugar,
    executante: req.body.executante,
    os_num: req.body.os_num,
    ans: req.body.ans,
    status2: req.body.status2,
    multitarefa: req.body.multitarefa
  }];
  let insert1 = db.$config.pgp.helpers.insert(data1, cs1) + " RETURNING id";
  db.tx('transaction', t => {
    return t.one(insert1)
      .then(returning => {
        console.log(returning)
        return t.batch(req.body.assetsList.map(asset => {
          return t.none(db.$config.pgp.helpers.insert([{
            wo_id: returning.id,
            asset_id: asset
          }], cs2))
        }));
      })
    .then(data => {
      res.json(data);
    })
    .catch(() => console.log('error /nova'))
  })
  // db.one("INSERT INTO teste VALUES (12323, 'ASLKDJFKLSDJF') RETURNING f1")
  // .then(data => {
  //   res.json(data)
  // })
  // .catch(() => console.log('error /nova'))
});

module.exports = router;