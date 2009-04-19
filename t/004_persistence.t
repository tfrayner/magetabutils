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
# $Id: 004_persistence.t 158 2008-12-29 17:31:11Z tfrayner $

# Basic tests for the Persistence module. FIXME this needs to be
# extended to test insertion, update, retrieval and deletion of all
# instantiable Bio::MAGETAB classes.

use strict;
use warnings;

use Test::More tests => 4;
use Test::Exception;
use File::Spec;

use Bio::MAGETAB;

my $dbfile = File::Spec->catfile('t','test_sqlite.db');
if ( -e $dbfile ) {
    unlink $dbfile or die("Error unlinking pre-existing test database file: $!");
}

my $dsn    = "dbi:SQLite:$dbfile";

SKIP: {

    eval {
        require Tangram;
        require DBI;
        require DBD::SQLite;
    };

    skip 'Tests require Tangram, DBI and DBD::SQLite to be installed',
	4 if $@;

    require_ok( 'Bio::GeneSigDB::Persistence');

    my $db;
    lives_ok( sub{ $db = Bio::GeneSigDB::Persistence->new( dbparams => [ $dsn ] )},
              'Persistence object instantiates okay');

    lives_ok( sub{ $db->deploy() }, 'and deploys database schema');

    lives_ok( sub{ $db->connect() }, 'to which we can successfully connect');

    # FIXME see the superclass tests for object insertion, update and
    # delete tests.

    unlink $dbfile or die("Error unlinking test database file: $!");
}
