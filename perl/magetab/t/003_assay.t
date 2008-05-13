#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Assay' );
}
INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

require Bio::MAGETAB::ControlledTerm;
require Bio::MAGETAB::ArrayDesign;

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 1, value => 2 );
my $ad = Bio::MAGETAB::ArrayDesign->new( name => 1 );

my %required_attr = (
    name           => 'test',
    technologyType => $ct,
);

my %optional_attr = (
    arrayDesign    => $ad,
);

my %bad_attr = (
    name           => [],
    technologyType => 'test',
    arrayDesign    => 'test',
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 1, value => 'test' );
my $ad2 = Bio::MAGETAB::ArrayDesign->new( name => 2 );

my %secondary_attr = (
    name           => 'test2',
    technologyType => $ct2,
    arrayDesign    => $ad2,
);

my $obj = test_class(
    'Bio::MAGETAB::Assay',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::Event'), 'object has correct superclass' );
