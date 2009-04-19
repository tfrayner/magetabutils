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
    use_ok( 'Bio::GeneSigDB::Category' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

my $parent;
lives_ok( sub { $parent = Bio::GeneSigDB::Category->new( name => 'parent cat' ) },
          'parent category instantiation succeeds' );

my %required_attr = (
    name         => 'test category',
);

my %optional_attr = (
    parentCategory => $parent,
);

my %bad_attr = (
    name           => [],
    parentCategory => 'bad',
);

my $parent2;
lives_ok( sub { $parent2 = Bio::GeneSigDB::Category->new( name => 'parent cat 2' ) },
          'parent category instantiation succeeds' );

my %secondary_attr = (
    name           => 'test category 2',
    parentCategory => $parent2,
);

my $obj = test_class(
    'Bio::GeneSigDB::Category',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::GeneSigDB'), 'object has correct superclass' );
