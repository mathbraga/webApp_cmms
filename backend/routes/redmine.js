const express = require('express');
const router = express.Router();
const got = require('got');

router.get(
  '/',
  async (req, res, next) => {
    const { page } = req.query;
    const { body } = await got.get(
      `https://redminesf.senado.gov.br/redmine/projects/solicitacoes-de-servico/issues.json?page=${page}&set_filter=1`,
      { headers: { "X-Redmine-API-Key": '' } },
    );
    res.json(body);
  }
);

module.exports = router;
