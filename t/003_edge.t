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
    use_ok( 'Bio::MAGETAB::Edge' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Source;
use Bio::MAGETAB::Sample;
use Bio::MAGETAB::Extract;
use Bio::MAGETAB::Protocol;
use Bio::MAGETAB::ProtocolApplication;

my $so = Bio::MAGETAB::Source->new(  name => 'test source'  );
my $sa = Bio::MAGETAB::Sample->new(  name => 'test sample'  );
my $ex = Bio::MAGETAB::Extract->new( name => 'test extract' );

my $pr = Bio::MAGETAB::Protocol->new( name => 'test protocol' );
my $pa = Bio::MAGETAB::ProtocolApplication->new(
    protocol => $pr,
    date     => '2008-01-01',
);

my %required_attr = (
    inputNode            => $so,
    outputNode           => $sa,
);

my %optional_attr = (
    protocolApplications => [ $pa ],
);

my %bad_attr = (
    inputNode            => [],
    outputNode           => 'test',
    protocolApplications => 'test',
);

my $pa2 = Bio::MAGETAB::ProtocolApplication->new(
    protocol => $pr,
    date     => '2008-01-02',
);

my %secondary_attr = (
    inputNode            => $sa,
    outputNode           => $ex,
    protocolApplications => [ $pa2 ],
);

my $obj = test_class(
    'Bio::MAGETAB::Edge',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );

my $ex2 = Bio::MAGETAB::Extract->new( name => 'test extract 2' );
my $ex3 = Bio::MAGETAB::Extract->new( name => 'test extract 3' );

# Test reciprocal relationship between nodes and edges.
is( $obj->get_outputNode(), $ex, 'initial state prior to reciprocity test' );
lives_ok( sub{ $obj->set_outputNode($ex2) }, 'setting outputNode via self' );
is_deeply( $ex2->get_inputEdges(), $obj, 'sets inputEdges in target node' );
lives_ok( sub{ $ex3->set_inputEdges( [ $obj ] ) }, 'setting inputEdges via target node' );
is( $obj->get_outputNode(), $ex3, 'sets outputNode in self' );