#!/usr/bin/env perl
use strict;
use warnings;

use feature 'say';

use JSON::XS;
use IO::File;

local $/;

my $data = IO::File->new('data.json')->getline;


my $obj = decode_json($data);


IO::File->new('data.json', 'w')->print(JSON::XS->new->canonical(1)->encode($obj));
# IO::File->new('data.json', 'w')->print(encode_json($obj));

