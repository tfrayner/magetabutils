#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::MatrixColumn' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::ControlledTerm;
use Bio::MAGETAB::Normalization;

my $no = Bio::MAGETAB::Normalization->new( name => 'test' );
my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'qt', value => 'test' );

my %required_attr = (
    columnNumber     => 20,
    quantitationType => $ct,
    referencedNodes  => [ $no ],
);

my %optional_attr = (
);

my %bad_attr = (
    columnNumber     => 'test',
    quantitationType => 'test',
    referencedNodes  => $no,
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'qt', value => 'test2' );
my $no2 = Bio::MAGETAB::Normalization->new( name => 'test2' );

my %secondary_attr = (
    columnNumber     => 22,
    quantitationType => $ct2,
    referencedNodes  => [ $no2 ],
);

my $obj = test_class(
    'Bio::MAGETAB::MatrixColumn',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
