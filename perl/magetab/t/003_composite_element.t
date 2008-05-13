#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::CompositeElement' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

require Bio::MAGETAB::DatabaseEntry;
require Bio::MAGETAB::Comment;

my @db;
for ( 1..3 ) {
    push @db, Bio::MAGETAB::DatabaseEntry->new( accession => $_ );
}

my @co;
for ( 1..3 ) {
    push @co, Bio::MAGETAB::Comment->new( name => 'test', value => $_ );
}


my %required_attr = (
    name           => 'test',
);

my %optional_attr = (
    comments          => \@co,
    databaseEntries   => \@db,
);

my %bad_attr = (
    name            => [],
    comments        => 'test',
    databaseEntries => 'test',
);

my @db2 = Bio::MAGETAB::DatabaseEntry->new( accession => 'test 2' );
my @co2 = Bio::MAGETAB::Comment->new( name => 'test', value => 'test 2' );

my %secondary_attr = (
    name              => 'test2',
    comments          => \@co2,
    databaseEntries   => \@db2,
);

my $obj = test_class(
    'Bio::MAGETAB::CompositeElement',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::DesignElement'), 'object has correct superclass' );
