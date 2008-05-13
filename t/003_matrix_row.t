#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::MatrixRow' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Reporter;

my $rp = Bio::MAGETAB::Reporter->new( name => 'test' );

my %required_attr = (
    rowNumber        => 21,
    designElement    => $rp,
);

my %optional_attr = (
);

my %bad_attr = (
    rowNumber        => 'test',
    designElement    => 'test',
);

my $rp2 = Bio::MAGETAB::Reporter->new( name => 'test 2' );

my %secondary_attr = (
    rowNumber        => 22,
    designElement    => $rp2,
);

my $obj = test_class(
    'Bio::MAGETAB::MatrixRow',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
