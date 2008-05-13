#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::DataFile' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

my %required_attr = (
    uri           => 'file://localhost/home/user/data.txt',
    format        => 'CEL',
);

my %optional_attr = (
);

my %bad_attr = (
    uri            => [],
    format         => [],
);

my %secondary_attr = (
    uri           => 'file://localhost2/home/user/data.txt',
    format        => 'CEL',
);

my $obj = test_class(
    'Bio::MAGETAB::DataFile',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::Data'), 'object has correct superclass' );
