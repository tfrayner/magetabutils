#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Publication' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::ControlledTerm;

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 1, value => 2 );

my %required_attr = (
);

my %optional_attr = (
    pubMedID   => '23998712',
    authorList => 'test authors',
    title      => 'test title',
    DOI        => '12342349o87',
    status     => $ct,
);

my %bad_attr = (
    pubMedID   => [],
    authorList => [],
    title      => [],
    DOI        => [],
    status     => 'test',
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 1, value => 4 );

my %secondary_attr = (
    pubMedID   => '23912',
    authorList => 'test authors 2',
    title      => 'test title 2',
    DOI        => '12342349o872',
    status     => $ct2,
);

my $obj = test_class(
    'Bio::MAGETAB::Publication',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
