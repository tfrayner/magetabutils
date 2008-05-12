#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::ControlledTerm' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

my %required_attr = (
    category      => 'test cat 1',
    value         => 'test val 1',
);

my %optional_attr = (
);

my %bad_attr = (
    category      => [],
    value         => [],
);

my %secondary_attr = (
    category      => 'test cat 2',
    value         => 'test val 2',
);

my $obj = test_class(
    'Bio::MAGETAB::ControlledTerm',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::DatabaseEntry'), 'object has correct superclass' );
