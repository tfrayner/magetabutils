#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Factor' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::ControlledTerm;
my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test' );

my %required_attr = (
    name           => 'test',
);

my %optional_attr = (
    type           => $ct,
);

my %bad_attr = (
    name           => [],
    type           => 'test',
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test 2' );

my %secondary_attr = (
    name           => 'test2',
    type           => $ct2,
);

my $obj = test_class(
    'Bio::MAGETAB::Factor',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
