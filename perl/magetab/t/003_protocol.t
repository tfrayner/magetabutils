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
    use_ok( 'Bio::MAGETAB::Protocol' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::ControlledTerm;

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'unit', value => 'name' );

my %required_attr = (
    name     => 'test',
);

my %optional_attr = (
    text     => 'test text',
    software => 'test software',
    hardware => 'test hardware',
    protocolType => $ct,
    contact  => 'nearly forgot this',
);

my %bad_attr = (
    name     => [],
    text     => [],
    software => [],
    hardware => [],
    protocolType => 'test',
    contact  => [],
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'unit', value => 'name 2' );

my %secondary_attr = (
    name     => 'test 2',
    text     => 'test text 2',
    software => 'test software 2',
    hardware => 'test hardware 2',
    protocolType => $ct2,
    contact  => 'another one',
);

my $obj = test_class(
    'Bio::MAGETAB::Protocol',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::DatabaseEntry'), 'object has correct superclass' );
