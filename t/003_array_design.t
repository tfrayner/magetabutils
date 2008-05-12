#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::ArrayDesign' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

require Bio::MAGETAB::ControlledTerm;
require Bio::MAGETAB::Comment;
require Bio::MAGETAB::Reporter;
require Bio::MAGETAB::CompositeElement;

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 1, value => 2 );
my @co = Bio::MAGETAB::Comment->new( name => 1, value => 2 );
my @de;
for ( 1..3 ) {
    push @de, Bio::MAGETAB::Reporter->new( name => "test $_" );
}

my %required_attr = (
    name        => 'test array design',
);

my %optional_attr = (
    accession           => 'A-TEST-1111',
    version             => '1.21b',
    uri                 => 'http://dummy.com/array_design.txt',
    technologyType      => $ct,
    surfaceType         => $ct,
    substrateType       => $ct,
    sequencePolymerType => $ct,
    printingProtocol    => 'test text here',
    provider            => 'simple string provider',
    designElements      => \@de,
    comments            => \@co,
);

my %bad_attr = (
    name                => [],
    accession           => [],
    version             => [],
    uri                 => [],
    technologyType      => 'test',
    surfaceType         => 'test',
    substrateType       => 'test',
    sequencePolymerType => 'test',
    printingProtocol    => [],
    provider            => [],
    designElements      => [qw(1 2 3)],
    comments            => 'test',
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 2, value => 3 );
my @co2 = Bio::MAGETAB::Comment->new( name => 2, value => 3 );
my @de2;
for ( 1..3 ) {
    push @de2, Bio::MAGETAB::Reporter->new( name => "test 2 $_" );
}

my %secondary_attr = (
    name                => 'test array design 2',
    accession           => 'A-TEST-1112',
    version             => '1.23b',
    uri                 => 'http://dummy.com/array_design2.txt',
    technologyType      => $ct2,
    surfaceType         => $ct2,
    substrateType       => $ct2,
    sequencePolymerType => $ct2,
    printingProtocol    => 'test text here 2',
    provider            => 'simple string provider 2',
    designElements      => \@de2,
    comments            => \@co2,
);

test_class(
    'Bio::MAGETAB::ArrayDesign',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);
