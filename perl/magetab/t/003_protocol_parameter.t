#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::ProtocolParameter' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Protocol;

my $prot = Bio::MAGETAB::Protocol->new( name => 'test protocol' );

my %required_attr = (
    name           => 'test',
    protocol       => $prot,
);

my %optional_attr = (
);

my %bad_attr = (
    name           => [],
    protocol       => 'test',
);

my $prot2 = Bio::MAGETAB::Protocol->new( name => 'test protocol' );

my %secondary_attr = (
    name           => 'test2',
    protocol       => $prot2,
);

my $obj = test_class(
    'Bio::MAGETAB::ProtocolParameter',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
