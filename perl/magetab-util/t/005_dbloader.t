#!/usr/bin/env perl
#
# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB::Util.
# 
# Bio::MAGETAB::Util is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB::Util is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB::Util.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

# Basic tests for the DBLoader module.

use strict;
use warnings;

use Test::More qw( no_plan ); #tests => 21;
use Test::Exception;
use File::Spec;

my $dbfile = File::Spec->catfile('t','test_sqlite.db');
if ( -e $dbfile ) {
    unlink $dbfile or die("Error unlinking pre-existing test database file: $!");
}

my $dsn = "dbi:SQLite:$dbfile";

SKIP: {

    eval {
        require Bio::MAGETAB::Util::Persistence;
    };

    skip 'Tests require Bio::MAGETAB::Util::Persistence to be loadable',
	1 if $@;

    my $db = Bio::MAGETAB::Util::Persistence->new({ dbparams => [ $dsn ] });
    $db->deploy();
    $db->connect();

    require_ok('Bio::MAGETAB::Util::DBLoader');

    my $loader;
    lives_ok( sub { $loader = Bio::MAGETAB::Util::DBLoader->new({ database => $db }) },
               'Loader instantiates okay' );

    # Start by trying some simple CRU(notD) with TermSource, which has
    # no complications (see below).
    {
        my $ts;
        lives_ok( sub { $ts = $loader->create_term_source({ name => 'test_term_source' }) },
                  'TermSource created' );
        ok( UNIVERSAL::isa( $ts, 'Bio::MAGETAB::TermSource' ), 'of the correct class' );
    }

    my $oid;
    {
        my $ts;
        lives_ok( sub { $ts = $loader->get_term_source({ name => 'test_term_source' }) },
                  'TermSource retrieved' );
        ok( UNIVERSAL::isa( $ts, 'Bio::MAGETAB::TermSource' ), 'of the correct class' );        
        dies_ok( sub { $ts = $loader->get_term_source({ name => 'not_the_correct_name' }) },
                 'non-existent TermSource is not retrieved' );
        $oid = $loader->get_database()->id( $ts );
    }

    {
        my $ts;
        lives_ok( sub { $ts = $loader->find_or_create_term_source({ name    => 'test_term_source',
                                                                    version => 0.9 }) },
                  'old TermSource find_or_created' );
        ok( UNIVERSAL::isa( $ts, 'Bio::MAGETAB::TermSource' ), 'of the correct class' );
        is( $oid, $loader->get_database()->id( $ts ), 'and identical to the original' );
        is( $ts->get_version(), 0.9, 'but with updated version attribute' );
    }

    {
        my $ts;
        lives_ok( sub { $ts = $loader->find_or_create_term_source({ name => 'new_term_source' }) },
                  'new TermSource find_or_created' );
        ok( UNIVERSAL::isa( $ts, 'Bio::MAGETAB::TermSource' ), 'of the correct class' );
    }

    # Now we test with Edges, where the ID depends on linked objects
    # (rather than strings).
    my ($m1, $m2);
    {
        lives_ok( sub { $m1 = $loader->find_or_create_source({ name => 'test_source' }) },
                  'new Source find_or_created' );
        lives_ok( sub { $m2 = $loader->find_or_create_sample({ name => 'test_sample' }) },
                  'new Sample find_or_created' );
        my $e;
        lives_ok( sub { $e = $loader->find_or_create_edge({ inputNode  => $m1,
                                                            outputNode => $m2, }) },
                  'new Edge find_or_created' );
        ok( UNIVERSAL::isa( $e, 'Bio::MAGETAB::Edge' ), 'of the correct class' );
        $oid = $loader->get_database()->id( $e );
    }
    {
        my $e;
        lives_ok( sub { $e = $loader->find_or_create_edge({ inputNode  => $m1,
                                                            outputNode => $m2, }) },
                  'old Edge find_or_created' );
        is( $oid, $loader->get_database()->id( $e ), 'identical to the original' );
    }

    # FIXME test for things where ID depends on aggregators; test for
    # update of ArrayRef attributes.

    # FIXME also test for creation and retrieval of DatabaseEntry with
    # TermSource and no namespace/authority.

    unlink $dbfile or die("Error unlinking test database file: $!");
}
