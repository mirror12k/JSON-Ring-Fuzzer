#!/usr/bin/env php
<?php
$data = file_get_contents("data.json");
$obj = json_decode($data);
file_put_contents('data.json', json_encode($obj));
