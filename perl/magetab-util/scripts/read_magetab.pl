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
#
#
# This is a very simplistic example script to illustrate how one might
# use the Reader modules to parse a MAGE-TAB document into
# Bio::MAGETAB objects in memory.

use strict;
use warnings;

use Getopt::Long;

use Bio::MAGETAB::Util::Reader;

our $VERSION;
my ( $idf, $is_relaxed, $authority, $namespace, $want_help, $want_version );

GetOptions(
    "i|idf=s"       => \$idf,
    "a|authority=s" => \$authority,
    "n|namespace=s" => \$namespace,
    "r|relaxed"     => \$is_relaxed,
);

if ( $want_help || ! ($idf && -r $idf) ) {

    print (<<"USAGE");

 Usage: read_magetab.pl -i <IDF file>

 Options:

    -r :   Use "relaxed" parsing, where undeclared objects are created for you on the fly.
    -n :   Use the specified namespace string.
    -a :   Use the specified authority string.
    -v :   Print version information.
    -h :   Print this help.

USAGE

    exit 255;
}

if ( $want_version ) {
    print "This is Bio::MAGETAB::Util::Reader version $VERSION\n";
    exit 255;
}

my $reader = Bio::MAGETAB::Util::Reader->new(
    idf            => $idf,
    relaxed_parser => $is_relaxed,
);

$reader->set_authority( $authority ) if defined $authority;
$reader->set_namespace( $namespace ) if defined $namespace;

$reader->parse();
