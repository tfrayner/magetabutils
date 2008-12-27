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

use strict;
use warnings;

use Bio::MAGETAB::Util::Persistence;
use Bio::MAGETAB;

use Getopt::Long;

my ( $dbtype, $dbname, $user, $pass );

GetOptions(
    "t|dbtype=s"   => \$dbtype,
    "d|dbname=s"   => \$dbname,
    "u|username=s" => \$user,
    "p|password=s" => \$pass,
);

# FIXME the following line could be expanded to other
# Tangram-supported database engines.
unless ( $dbname && grep { $dbtype eq $_ } qw( mysql SQLite ) ) {
    print <<"USAGE";

Usage: $0 -t <database engine e.g. mysql> -d <database name>

USAGE

    exit 255;
}

if ( $dbtype eq 'SQLite' && -e $dbname ) {
    die("Error: database file $dbname already exists.\n");
}

my $dsn = "dbi:$dbtype:$dbname";

my $db = Bio::MAGETAB::Util::Persistence->new( dbparams => [ $dsn ] );

$db->deploy();
