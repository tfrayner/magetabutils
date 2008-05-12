#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::DatabaseEntry' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::TermSource;
my $ts = Bio::MAGETAB::TermSource->new( name => 'test term source' );

my %required_attr = (
);

my %optional_attr = (
    accession     => 'test acc 1',
    termSource    => $ts,
);

my %bad_attr = (
    accession     => [],
    termSource    => 'not a term source',
);

my $ts2 = Bio::MAGETAB::TermSource->new( name => 'test term source 2' );
my %secondary_attr = (
    accession     => 'test acc 2',
    termSource    => $ts2,
);

my $obj = test_class(
    'Bio::MAGETAB::DatabaseEntry',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
