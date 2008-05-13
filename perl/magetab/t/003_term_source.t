#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::TermSource' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

my %required_attr = (
    name    => 'test',
);

my %optional_attr = (
    version => 1,
    uri     => 'http://www.terms-are-us.org/listing.txt',
);

my %bad_attr = (
    name    => [],
    version => [],
    uri     => [],
);

my %secondary_attr = (
    name    => 'test2',
    version => '1.342rc',
    uri     => 'file://localhost/terms.txt',
);

my $obj = test_class(
    'Bio::MAGETAB::TermSource',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
