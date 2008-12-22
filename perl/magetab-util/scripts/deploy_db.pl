#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Bio::MAGETAB::Util::Persistence;

use Bio::MAGETAB;

my $db = Bio::MAGETAB::Util::Persistence->new();

my $dsn = 'dbi:SQLite:test_tangram.db'; 

$db->deploy( $dsn );

my $store = $db->connect( $dsn );

my $cv = Bio::MAGETAB::ControlledTerm->new({ category => 'testcat',
                                             value    => 'testval', });
$store->insert( $cv );
$store->insert( Bio::MAGETAB::Sample->new({ name      => 'test_sample',
                                            namespace => 'me',
                                            type      => $cv, }) );
