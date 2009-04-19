#!/usr/bin/env perl
#
# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::GeneSigDB.
# 
# Bio::GeneSigDB is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::GeneSigDB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::GeneSigDB.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id: 002_base_class.t 127 2008-12-01 10:00:08Z tfrayner $

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;

BEGIN {
    use_ok( 'Bio::GeneSigDB' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_methods);
}

dies_ok( sub { Bio::GeneSigDB->new() }, 'abstract class cannot be instantiated' );

# Very basic tests that methods exist. Anything more would require
# instantiation.
my @expected = qw(
);

test_methods( 'Bio::GeneSigDB', \@expected );
