#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Contact' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

require Bio::MAGETAB::ControlledTerm;
require Bio::MAGETAB::Comment;

my @ct;
for ( 1..3 ) {
    push @ct, Bio::MAGETAB::ControlledTerm->new( category => 'test', value => $_ );
}

my @co;
for ( 1..3 ) {
    push @co, Bio::MAGETAB::Comment->new( name => 'test', value => $_ );
}

my %required_attr = (
    lastName       => 'rabbit',
);

my %optional_attr = (
    firstName    => 'roger',
    midInitials  => 't',
    email        => 'roger@dodger.com',
    organization => 'test',
    phone        => '001 1234356',
    fax          => '002 2737482',
    address      => 'somewhere, someplace',
    roles        => \@ct,
    comments     => \@co,
);

my %bad_attr = (
    lastName     => [],
    firstName    => [],
    midInitials  => [],
    email        => [],
    organization => [],
    phone        => [],
    fax          => [],
    address      => [],
    roles        => 'test',
    comments     => 'test',
);

my @ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test 2' );
my @co2 = Bio::MAGETAB::Comment->new( name => 'test', value => 'test 2' );

my %secondary_attr = (
    lastName     => 'test 2',
    firstName    => 'test 2',
    midInitials  => 't 2',
    email        => 'roger2@dodger.com',
    organization => 'test 2',
    phone        => '001 134356',
    fax          => '002 237482',
    address      => 'somewhere, someplace else',
    roles        => \@ct2,
    comments     => \@co2,
);

my $obj = test_class(
    'Bio::MAGETAB::Contact',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
