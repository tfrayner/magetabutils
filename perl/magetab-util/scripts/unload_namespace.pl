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

# This is a very basic unloader script for data stored using the
# DBLoader/Persistence back-end. No doubt more sophisticated unloading
# procedures can be devised, but this works well enough for now.

use strict;
use warnings;

use Getopt::Long;
use DBI;

my ( $dsn, $namespace, $authority );

GetOptions(
    "n|namespace=s" => \$namespace,
    "d|dsn=s"       => \$dsn,
    "a|authority=s" => \$authority,
);

unless ( defined $namespace && defined $authority && $dsn ) {
    die <<"USAGE";
Usage: $0 -d <DSN or SQLite file name> -n namespace -a authority
USAGE

}

unless ( $dsn =~ /\A dbi:\w+:\w+ /ixms ) {
    $dsn = "dbi:SQLite:$dsn";
}

my $dbh = DBI->connect( $dsn ) or die("Error: Unable to connect to database.");

# A list of classes, in the order in which we will delete them:
my @classes = qw(
                    FactorValue
                    Factor
                    SDRFRow
                    SDRF
                    Investigation
                    ParameterValue
                    ProtocolApplication
                    ProtocolParameter
                    Protocol
                    LabeledExtract
                    Event
                    MatrixRow
                    MatrixColumn
                    Data
                    DesignElement
                    ArrayDesign
                    DatabaseEntry
                    Comment
            );

foreach my $class ( @classes ) {

    warn ("Deleting members of class $class...\n");

    my $sth = $dbh->prepare(<<"QUERY");
delete from Bio_MAGETAB_$class where id in (select id from Bio_MAGETAB_BaseClass where namespace=? and authority=?)
QUERY

    $sth->execute( $namespace, $authority )
        or die( $sth->errstr );
    $sth->finish();
}

# And the coup de grace:
warn ("Deleting remaining objects...\n");
my $sth = $dbh->prepare(<<'QUERY');
delete from Bio_MAGETAB_BaseClass where namespace=? and authority=?;
QUERY

$sth->execute( $namespace, $authority )
    or die( $sth->errstr );
$sth->finish();

warn ("Done.\n");
