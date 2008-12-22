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
    use_ok( 'Bio::MAGETAB::ParameterValue' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Protocol;
use Bio::MAGETAB::ProtocolParameter;
use Bio::MAGETAB::Measurement;
use Bio::MAGETAB::Comment;

my $prot = Bio::MAGETAB::Protocol->new( name => 'test protocol' );
my $parm = Bio::MAGETAB::ProtocolParameter->new( name => 'test param', protocol => $prot );
my $meas = Bio::MAGETAB::Measurement->new( measurementType => 'test measurement', value => 'value' );
my $comm = Bio::MAGETAB::Comment->new( name => 'test comment', value => 'of interest' );

my %required_attr = (
    measurement => $meas,
    parameter   => $parm,
);

my %optional_attr = (
    comments    => [ $comm ],
);

my %bad_attr = (
    measurement => 'test',
    parameter   => 'test',
    comments    => 'test',
);

my $prot2 = Bio::MAGETAB::Protocol->new( name => 'test protocol' );
my $parm2 = Bio::MAGETAB::ProtocolParameter->new( name => 'test param', protocol => $prot2 );
my $meas2 = Bio::MAGETAB::Measurement->new( measurementType => 'test measurement', value => 'value' );
my $comm2 = Bio::MAGETAB::Comment->new( name => 'test comment', value => 'of interest' );

my %secondary_attr = (
    measurement => $meas2,
    parameter   => $parm2,
    comments    => [ $comm2 ],
);

my $obj = test_class(
    'Bio::MAGETAB::ParameterValue',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
