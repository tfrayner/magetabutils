#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Reporter' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

require Bio::MAGETAB::DatabaseEntry;
require Bio::MAGETAB::ControlledTerm;
require Bio::MAGETAB::CompositeElement;

my @db;
for ( 1..3 ) {
    push @db, Bio::MAGETAB::DatabaseEntry->new( accession => $_ );
}

my @ce;
for ( 1..3 ) {
    push @ce, Bio::MAGETAB::CompositeElement->new( name => 'test' );
}

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test' );

my %required_attr = (
    name              => 'test',
);

my %optional_attr = (
    controlType       => $ct,
    groups            => [ $ct ],
    sequence          => 'atcg',
    databaseEntries   => \@db,
    compositeElements => \@ce,
);

my %bad_attr = (
    name              => [],
    controlType       => 'test',
    groups            => 'test',
    sequence          => [],
    databaseEntries   => \@ce,
    compositeElements => \@db,
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test 2' );

my %secondary_attr = (
    name              => 'test2',
    controlType       => $ct2,
    groups            => [ $ct2 ],
    sequence          => 'atcg',
    databaseEntries   => [ $db[0] ],
    compositeElements => [ $ce[1] ],
);

my $obj = test_class(
    'Bio::MAGETAB::Reporter',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::DesignElement'), 'object has correct superclass' );
