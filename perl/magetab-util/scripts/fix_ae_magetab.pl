#!/usr/bin/env perl
#
# Copyright 2009 Tim Rayner
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

# This is a simple utility script which can be used to convert the
# current ArrayExpress implementation of the MAGE-TAB format into
# something that the MAGE-TAB Utilities API can reliably read. The
# changes are principally to bring the format into line with the
# MAGE-TAB v1.1 specification, and to fix some common errors. The aim
# is that the output of this script can be parsed using the MAGE-TAB
# Reader classes running in "strict" mode.

use strict;
use warnings;

use Getopt::Long;
use File::Temp qw(tempfile);
use File::Copy;
use Bio::MAGETAB::Util::Reader::Tabfile;

my $VERSION = 0.01;

########
# SUBS #
########

sub rewrite_sdrf {

    my ( $sdrf ) = @_;

    my $sdrf_parser = Bio::MAGETAB::Util::Reader::Tabfile->new(
        uri => $sdrf,
    );

    my ( $out_fh, $outfile ) = tempfile();

    local $/ = $sdrf_parser->get_eol_char();

    # Header
    my $harry = $sdrf_parser->getline();
    $harry = $sdrf_parser->strip_whitespace( $harry );
    my @tscols;
    for ( my $i = 0; $i < @$harry; $i++ ) {

        # Record the columns containing TSs.
        if ( $harry->[$i] =~ /Term *Source *REFs?/i ) {
            push @tscols, $i;
        }

        # Rewrite Protocol REF columns to remove prefixes.
        if ( $harry->[$i] =~ /Protocol *REFs?/i ) {
            $harry->[$i] = 'Protocol REF';
        }
    }
    $sdrf_parser->print( $out_fh, $harry );

    # Body
    my %termsource;
    while ( my $larry = $sdrf_parser->getline() ) {
        $larry = $sdrf_parser->strip_whitespace( $larry );

        foreach my $col ( @tscols ) {
            my $ts = $larry->[$col];
            $termsource{$ts}++;
        }

        $sdrf_parser->print( $out_fh, $larry );
    }
    $sdrf_parser->confirm_full_parse();

    # Replace the original SDRF with the new one.
    close( $out_fh );
    copy( $outfile, $sdrf_parser->get_uri()->path() )
        or die("Error: unable to overwrite old SDRF: $!");

    return [ keys %termsource ];
}

sub rewrite_idf {

    my ( $idf, $termsources ) = @_;

    my $idf_parser = Bio::MAGETAB::Util::Reader::Tabfile->new(
        uri => $idf,
    );

    local $/ = $idf_parser->get_eol_char();
    while ( my $larry = $idf_parser->getline() ) {
        $larry = $idf_parser->strip_whitespace( $larry );
    }
    $idf_parser->confirm_full_parse();

    return;
}

########
# MAIN #
########

my ( $idf, $sdrf, $want_version, $want_help );

GetOptions(
    "i|idf=s"      => \$idf,
    "s|sdrf=s"     => \$sdrf,
    "v|version"    => \$want_version,
    "h|help"       => \$want_help,
);

if ( $want_version ) {
    print (<<"OUTPUT");
This is fix_ae_magetab.pl version $VERSION
OUTPUT

    exit 255;
}

if ( $want_help || ! ( $idf && $sdrf ) ) {
    print (<<"USAGE");
Usage: fix_ae_magetab.pl -i <idf> -s <sdrf>
USAGE

    exit 255;
}

# SDRF
my $termsources = rewrite_sdrf( $sdrf );

# IDF
rewrite_idf( $idf, $termsources );

