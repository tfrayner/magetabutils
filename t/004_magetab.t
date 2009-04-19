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
    use_ok( 'Bio::GeneSigDB::MAGETAB' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

require Bio::MAGETAB::Investigation;
require Bio::MAGETAB::FactorValue;
require Bio::MAGETAB::Factor;
require Bio::MAGETAB::ControlledTerm;

my $inv    = Bio::MAGETAB::Investigation->new( title => 'test inv' );
my $factor = Bio::MAGETAB::Factor->new( name => 'test factor' );
my $testval = Bio::MAGETAB::ControlledTerm->new( category => 'test cat',
                                                 value    => 'test val' );
my $test    = Bio::MAGETAB::FactorValue->new( factor => $factor,
                                              term   => $testval );
my $refval  = Bio::MAGETAB::ControlledTerm->new( category => 'test cat 2',
                                                 value    => 'test val 2' );
my $ref     = Bio::MAGETAB::FactorValue->new( factor => $factor,
                                              term   => $refval );

my %required_attr = (
    investigation => $inv,
    test          => $test,
    reference     => $ref,
);

my %optional_attr = (
    bibref     => 'test reference',
    notes      => 'test notes',
);

my %bad_attr = (
    investigation => 'bad',
    test          => 'bad',
    reference     => 'bad',
    bibref        => [],
    notes         => [],
);

my $inv2    = Bio::MAGETAB::Investigation->new( title => 'test inv 2' );
my $test2    = Bio::MAGETAB::FactorValue->new( factor => $factor,
                                               term   => $refval );
my $ref2     = Bio::MAGETAB::FactorValue->new( factor => $factor,
                                               term   => $testval );

my %secondary_attr = (
    investigation => $inv2,
    test          => $test2,
    reference     => $ref2,
    bibref     => 'test reference 2',
    notes      => 'test notes 2',
);

my $obj = test_class(
    'Bio::GeneSigDB::MAGETAB',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::GeneSigDB::Provenance'), 'object has correct superclass' );
