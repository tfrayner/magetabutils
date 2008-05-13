#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Comment' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

my %required_attr = (
    name           => 'test',
    value          => 'test',
);

my %optional_attr = (
);

my %bad_attr = (
    name           => [],
    value          => [],
);

my %secondary_attr = (
    name           => 'test2',
    value          => 'test2',
);

my $obj = test_class(
    'Bio::MAGETAB::Comment',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
