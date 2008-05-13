#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Protocol' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::ControlledTerm;

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'unit', value => 'name' );

my %required_attr = (
    name     => 'test',
);

my %optional_attr = (
    text     => 'test text',
    software => 'test software',
    hardware => 'test hardware',
    type     => $ct,
);

my %bad_attr = (
    name     => [],
    text     => [],
    software => [],
    hardware => [],
    type     => 'test',
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'unit', value => 'name 2' );

my %secondary_attr = (
    name     => 'test 2',
    text     => 'test text 2',
    software => 'test software 2',
    hardware => 'test hardware 2',
    type     => $ct2,
);

my $obj = test_class(
    'Bio::MAGETAB::Protocol',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
