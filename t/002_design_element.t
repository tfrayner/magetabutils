#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;

BEGIN {
    use_ok( 'Bio::MAGETAB::DesignElement' );
}

dies_ok( sub { Bio::MAGETAB::DesignElement->new() }, 'abstract class cannot be instantiated' );
