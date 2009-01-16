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


# This is a very simplistic example script to illustrate how one might
# use the Reader modules to parse a MAGE-TAB document into
# Bio::MAGETAB objects in memory or in a database, and generate an
# output Graphviz visualization.

use strict;
use warnings;

use Getopt::Long;

use Bio::MAGETAB::Util::Reader;
use Bio::MAGETAB::Util::Writer::Graphviz;

my ( $idf,
     $is_relaxed,
     $ignore_datafiles,
     $authority,
     $namespace,
     $want_help,
     $want_version,
     $graph_file,
     $db_file );

GetOptions(
    "i|idf=s"       => \$idf,
    "a|authority=s" => \$authority,
    "n|namespace=s" => \$namespace,
    "r|relaxed"     => \$is_relaxed,
    "x|ignore-data" => \$ignore_datafiles,
    "g|graph=s"     => \$graph_file,
    "d|database=s"  => \$db_file,
    "h|help"        => \$want_help,
    "v|version"     => \$want_version,
);

if ( $want_help || ! ($idf && -r $idf) ) {

    print (<<"USAGE");

 Usage: read_magetab.pl -i <IDF file>

 Options:

    -r :   Use "relaxed" parsing, where undeclared objects are created for you on the fly.
    -x :   Do not attempt to parse any data files listed in the SDRF (specifically, data matrices).
    -n :   Use the specified namespace string.
    -a :   Use the specified authority string.
    -g :   Filename to use for the ".dot" file if attempting to draw a graph of the SDRF using Graphviz.
    -d :   SQLite database file to load the generated objects into.

    -v :   Print version information.
    -h :   Print this help.

USAGE

    exit 255;
}

if ( $want_version ) {
    print "This is Bio::MAGETAB::Util::Reader version $Bio::MAGETAB::Util::Reader::VERSION\n";
    exit 255;
}

$namespace ||= q{};
$authority ||= q{};

my $reader = Bio::MAGETAB::Util::Reader->new(
    idf              => $idf,
    relaxed_parser   => $is_relaxed,
    ignore_datafiles => $ignore_datafiles,
    namespace        => $namespace,
    authority        => $authority,
);

# If a database file was specified, dump the Investigation and all
# associated objects into a SQLite schema.
if ( $db_file ) {

    # We default to SQLite here for the sake of simplicity. In
    # principle, any database backend supported by Tangram should
    # work. NOTE that during testing, SQLite performance didn't scale
    # terribly well; MySQL worked better.
    require Bio::MAGETAB::Util::Persistence;
    require Bio::MAGETAB::Util::DBLoader;
    my $db = Bio::MAGETAB::Util::Persistence->new({
        dbparams => ["dbi:SQLite:$db_file"],
    });

    # If this is a new file (recommended), deploy the schema.
    unless ( -e $db_file ) {
        $db->deploy();
    }

    # Connect to the database and dump the objects.
    $db->connect();

    my $builder = Bio::MAGETAB::Util::DBLoader->new({
        database  => $db,
        namespace => $namespace,
        authority => $authority,
    });

    $reader->set_builder( $builder );
}

# Parse the IDF and any associated SDRFs/ADFs.
$reader->parse();

# If a graph file was specified, attempt to use Graphviz to draw the
# experimental design graph.
if ( $graph_file ) {

    open ( my $fh, '>', $graph_file )
        or die("Error: Unable to open output file: $!");

    my $writer = Bio::MAGETAB::Util::Writer::Graphviz->new({
        magetab    => $reader->get_builder()->get_magetab(),
        filehandle => $fh,
    });

    $writer->draw();

    my $pngfile = "$graph_file.png";

    print STDOUT ("Creating PNG graph file...\n");

    system(qq{dot -Tpng -o "$pngfile" "$graph_file"}) == 0
        or print STDERR (
            "Error: Graph drawing requires that the Graphviz 'dot' program is installed and on your executable path.\n"
        );
}