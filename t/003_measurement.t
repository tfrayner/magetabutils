#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Measurement' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::ControlledTerm;

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'unit', value => 'name' );

my %required_attr = (
    type     => 'test',
);

my %optional_attr = (
    unit     => $ct,
    value    => 0,
    minValue => 1,
    maxValue => 'two',
);

my %bad_attr = (
    type     => [],
    unit     => '',
    value    => [],
    minValue => [],
    maxValue => [],
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'unit', value => 'name 2' );

my %secondary_attr = (
    type     => 'test2',
    unit     => $ct2,
    value    => 'zero',
    minValue => 1_000_000_000,
    maxValue => -0.02,
);

my $obj = test_class(
    'Bio::MAGETAB::Measurement',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
