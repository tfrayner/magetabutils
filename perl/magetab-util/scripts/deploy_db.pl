#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Bio::MAGETAB::Util::Persistence;
use Bio::MAGETAB;

use Getopt::Long;

my ( $dbtype, $dbname, $user, $pass );

GetOptions(
    "t|dbtype=s"   => \$dbtype,
    "d|dbname=s"   => \$dbname,
    "u|username=s" => \$user,
    "p|password=s" => \$pass,
);

# FIXME the following line could be expanded to other
# Tangram-supported database engines.
unless ( $dbname && grep { $dbtype eq $_ } qw( mysql SQLite ) ) {
    print <<"USAGE";

Usage: $0 -t <database engine e.g. mysql> -d <database name>

USAGE

    exit 255;
}

if ( $dbtype eq 'SQLite' && -e $dbname ) {
    die("Error: database file $dbname already exists.\n");
}

my $db = Bio::MAGETAB::Util::Persistence->new();

my $dsn = "dbi:$dbtype:$dbname";

$db->deploy( $dsn );

my $store = $db->connect( $dsn );

my $cv = Bio::MAGETAB::ControlledTerm->new({ category => 'testcat',
                                             value    => 'testval', });
$store->insert( $cv );
$store->insert( Bio::MAGETAB::Sample->new({ name         => 'test_sample',
                                            namespace    => 'me',
                                            materialType => $cv, }) );
