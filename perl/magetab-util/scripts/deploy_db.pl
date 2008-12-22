#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Bio::MAGETAB::Util::Persistence;

use DBI;

my $store = Bio::MAGETAB::Util::Persistence->new();

my $dbh = DBI->connect('dbi:SQLite:test_tangram.db');

$store->deploy( $dbh );

$dbh->disconnect();
