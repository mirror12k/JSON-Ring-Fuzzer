#!/usr/bin/env node

var fs = require('fs');

var data = fs.readFileSync('data.json', 'utf8');
var obj = JSON.parse(data);

fs.writeFileSync('data.json', JSON.stringify(obj));
