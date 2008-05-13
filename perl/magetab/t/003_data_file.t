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

BEGIN {
    use_ok( 'Bio::MAGETAB::DataFile' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

my %required_attr = (
    uri           => 'file://localhost/home/user/data.txt',
    format        => 'CEL',
);

my %optional_attr = (
);

my %bad_attr = (
    uri            => [],
    format         => [],
);

my %secondary_attr = (
    uri           => 'file://localhost2/home/user/data.txt',
    format        => 'CEL',
);

my $obj = test_class(
    'Bio::MAGETAB::DataFile',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::Data'), 'object has correct superclass' );
