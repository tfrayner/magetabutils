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

my %required_attr = (
);

my %optional_attr = (
);

my %bad_attr = (
);

my %secondary_attr = (
);

my $obj = test_class(
    'Bio::MAGETAB::Assay',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::Node'), 'object has correct superclass' );
