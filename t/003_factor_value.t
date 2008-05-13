#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::FactorValue' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Factor;
use Bio::MAGETAB::ControlledTerm;
use Bio::MAGETAB::Measurement;

my $fa = Bio::MAGETAB::Factor->new( name => 'test factor' );
my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test controlled term' );
my $me = Bio::MAGETAB::Measurement->new( type => 'test measurement', value => 'test' );

my %required_attr = (
    factor      => $fa,
);

my %optional_attr = (
    measurement => $me,
    term        => $ct,
    channel     => $ct,
);

my %bad_attr = (
    factor      => 'test',
    measurement => 'test',
    term        => 'test',
    channel     => 'test',
);

my $fa2 = Bio::MAGETAB::Factor->new( name => 'test factor2' );
my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'test2', value => 'test controlled term' );
my $me2 = Bio::MAGETAB::Measurement->new( type => 'test measurement2', value => 'test' );

my %secondary_attr = (
    factor      => $fa2,
    measurement => $me2,
    term        => $ct2,
    channel     => $ct2,
);

my $obj = test_class(
    'Bio::MAGETAB::FactorValue',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
