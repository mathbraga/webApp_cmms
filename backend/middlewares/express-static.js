const express = require('express');
const path = require('path');
const paths = require('../paths');

exports.expressStatic = express.static(path.join(process.cwd(), paths.public));
exports.loginStatic = express.static(path.join(process.cwd(), "/public/login"));
