#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Feature' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Reporter;

my $rp = Bio::MAGETAB::Reporter->new( name => 'test reporter' );

my %required_attr = (
    blockColumn => 1,
    blockRow    => 2,
    column      => 3,
    row         => 4,
    reporter    => $rp,
);

my %optional_attr = (
);

my %bad_attr = (
    blockColumn => {},
    blockRow    => [],
    column      => 'x',
    row         => [],
    reporter    => 'test',
);

my $rp2 = Bio::MAGETAB::Reporter->new( name => 'test reporter 2' );

my %secondary_attr = (
    blockColumn => 12,
    blockRow    => 22,
    column      => 32,
    row         => 42,
    reporter    => $rp2,
);

my $obj = test_class(
    'Bio::MAGETAB::Feature',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::DesignElement'), 'object has correct superclass' );
