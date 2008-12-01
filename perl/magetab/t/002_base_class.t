#!/usr/bin/env perl
#
# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB.
# 
# Bio::MAGETAB is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;

BEGIN {
    use_ok( 'Bio::MAGETAB::BaseClass' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_methods);
}

dies_ok( sub { Bio::MAGETAB::BaseClass->new() }, 'abstract class cannot be instantiated' );

# Very basic tests that methods exist. Anything more would require
# instantiation.
my @expected = qw(
    get_ClassContainer
    get_authority
    get_namespace
    set_ClassContainer
    set_authority
    set_namespace
    has_ClassContainer
    has_authority
    has_namespace
    clear_authority
    clear_namespace
);

test_methods( 'Bio::MAGETAB::BaseClass', \@expected );
