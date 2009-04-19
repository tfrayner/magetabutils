#!/usr/bin/env perl
#
# Copyright 2009 Tim Rayner
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
# $Id: 003_array_design.t 50 2008-06-17 06:47:44Z tfrayner $

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;

BEGIN {
    use_ok( 'Bio::GeneSigDB::Element' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

require Bio::GeneSigDB::Database;

my $platform = Bio::GeneSigDB::Database->new(
    name => 'test database',
    uri  => 'http://test.com',
);

my %required_attr = (
    identifier => 'test element',
    platform   => $platform,
);

my %optional_attr = (
);

my %bad_attr = (
    identifier => [],
    platform   => 'bad',
);

my $platform2 = Bio::GeneSigDB::Database->new(
    name => 'test database 2',
    uri  => 'http://test2.com',
);

my %secondary_attr = (
    identifier => 'test element 2',
    platform   => $platform2,
);

my $obj = test_class(
    'Bio::GeneSigDB::Element',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::GeneSigDB'), 'object has correct superclass' );
