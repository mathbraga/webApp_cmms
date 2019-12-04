const express = require('express');
const config = require('./config');

module.exports = express.static(config.root, config.options);