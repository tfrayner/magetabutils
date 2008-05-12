#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;

BEGIN {
    use_ok( 'Bio::MAGETAB::Event' );
}

dies_ok( sub { Bio::MAGETAB::Event->new() }, 'abstract class cannot be instantiated' );
