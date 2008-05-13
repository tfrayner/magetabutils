#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Extract' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::ControlledTerm;
use Bio::MAGETAB::Measurement;

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test' );
my $me = Bio::MAGETAB::Measurement->new( type => 'test', value => 'test' );

my %required_attr = (
    name           => 'test',
);

my %optional_attr = (
    type            => $ct,
    characteristics => [ $ct ],
    measurements    => [ $me ],
);

my %bad_attr = (
    name            => [],
    type            => 'test',
    characteristics => [ 'test' ],
    measurements    => 'test',
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test 2' );
my $me2 = Bio::MAGETAB::Measurement->new( type => 'test', value => 'test' );

my %secondary_attr = (
    name            => 'test2',
    type            => $ct2,
    characteristics => [ $ct2 ],
    measurements    => [ $me2 ],
);

my $obj = test_class(
    'Bio::MAGETAB::Extract',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::Material'), 'object has correct superclass' );
