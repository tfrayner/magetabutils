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
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;

BEGIN {
    use_ok( 'Bio::GeneSigDB::PublishedSignature' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

require Bio::GeneSigDB::Category;
require Bio::GeneSigDB::Element;
require Bio::GeneSigDB::Database;
require Bio::GeneSigDB::Provenance;

my $platform = Bio::GeneSigDB::Database->new(
    name => 'test database',
    uri  => 'http://test.com',
);
my @cats = Bio::GeneSigDB::Category->new( name => 1 );
my @elem;
for ( 1..3 ) {
    push @elem, Bio::GeneSigDB::Element->new(
        identifier => "test $_",
        platform   => $platform,
    );
}

my $parent;
lives_ok( sub { $parent = Bio::GeneSigDB::Signature->new(
    name     => 'parent sig',
    species  => 'test species',
    elements => \@elem,
);}, 'test parent signature instantiates okay');

my $prov = Bio::GeneSigDB::Provenance->new(bibref => 'test bibref');

my %required_attr = (
    name        => 'test signature',
    species     => 'test species',
    elements    => \@elem,
    provenance  => $prov,
    criteria    => 'test criteria',
);

my %optional_attr = (
    parentSignature  => $parent,
    categories       => \@cats,
    notes            => 'test notes',
);

my %bad_attr = (
    name             => [],
    species          => [],
    elements         => 'bad',
    parentSignature  => 'bad',
    categories       => [ 'bad' ],
    notes            => [],
    provenance       => 'bad',
    criteria         => [],
);

my @cats2 = Bio::GeneSigDB::Category->new( name => 1 );
my @elem2;
for ( 1..3 ) {
    push @elem2, Bio::GeneSigDB::Element->new(
        identifier => "test $_ part 2",
        platform   => $platform,
    );
}

my $parent2;
lives_ok( sub { $parent2 = Bio::GeneSigDB::Signature->new(
    name     => 'parent sig2',
    species  => 'test species2',
    elements => \@elem2,
);}, 'test parent signature instantiates okay');

my $prov2 = Bio::GeneSigDB::Provenance->new(bibref => 'test bibref 2');

my %secondary_attr = (
    name             => 'test sig2',
    species          => 'test species2',
    elements         => \@elem2,
    parentSignature  => $parent2,
    categories       => \@cats2,
    notes            => 'test notes2',
    provenance       => $prov2,
    criteria         => 'test criteria 2',
);

my $obj = test_class(
    'Bio::GeneSigDB::PublishedSignature',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::GeneSigDB'), 'object has correct superclass' );
