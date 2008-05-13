#!/usr/bin/env perl
#
# $Id: 003_term_source.t 891 2008-05-09 23:51:17Z tfrayner $

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::SDRF' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Normalization;

my $norm = Bio::MAGETAB::Normalization->new( name => 'test norm' );

my %required_attr = (
    nodes          => [ $norm ],
    uri            => 'file://localhost/data/sdrf1.txt',
);

my %optional_attr = (
);

my %bad_attr = (
    nodes          => 'test',
    uri            => [],
);

my $norm2 = Bio::MAGETAB::Normalization->new( name => 'test norm 2' );

my %secondary_attr = (
    nodes          => [ $norm, $norm2 ],
    uri            => 'file://localhost/data/sdrf2.txt',
);

my $obj = test_class(
    'Bio::MAGETAB::SDRF',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
