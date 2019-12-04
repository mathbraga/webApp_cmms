const express = require('express');
const config = require('./config');

module.exports = express.json(config);