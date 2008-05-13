#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::DataAcquisition' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

my %required_attr = (
    name           => 'test',
);

my %optional_attr = (
);

my %bad_attr = (
    name           => [],
);

my %secondary_attr = (
    name           => 'test 2',
);

my $obj = test_class(
    'Bio::MAGETAB::DataAcquisition',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::Event'), 'object has correct superclass' );
