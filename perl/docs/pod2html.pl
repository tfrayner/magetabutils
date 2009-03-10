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

use 5.8.0;    # Need a recent Pod::HTML, which only comes with newer Perls

use strict;
use warnings;

use Pod::Html;
use File::Spec;

use Getopt::Long;
use File::Find;
use File::Path;
use Cwd;

sub transcode {

    my ( $in ) = @_;

    my $out = '';
    my $i;
    for ( $i = 0; $i < length( $in ); $i++ ) {
        $out .= "&#" . ord(substr($in, $i, 1)) .";";
    }

    return $out;
}

sub mangle_email {

    my ( $html ) = @_;

    open( my $fh, '<', $html )
        or die("Error opening HTML file: $!\n");

    my @lines = <$fh>;
    close( $fh ) or die($!);

    open( my $out, '>', $html )
        or die("Error opening HTML file: $!\n");
    foreach my $line ( @lines ) {

        # Very simplistic email detection.
        if ( my ( $email ) = ( $line =~ m/ \b ( \w+ \@ [\w\.-]+ ) \b /xms ) ) {
            my $mangled = transcode( $email );
            $line =~ s/$email/$mangled/g;
        }
        print $out $line;
    }
}

sub base_wanted {

    my ( $libdir, $cwd, $modules ) = @_;

    return unless $_ =~ m/ \.pm \z/xms;
    
    my $modfile = File::Spec->abs2rel( $File::Find::name, $libdir );
    my $htmldoc = File::Spec->rel2abs( $modfile, $cwd );

    # Replace extension.
    $htmldoc =~ s! \.p[mlh] \z!\.html!ixms;

    my ( $vol, $dir, $name ) = File::Spec->splitpath( $htmldoc );
    mkpath( $dir );

    print "Creating $htmldoc\n";
        
    pod2html(
        "--infile=$File::Find::name",
        "--outfile=$htmldoc",
        "--css=/style.css",
        "--noindex",
        "--htmlroot=/model",
        #        "--podroot=model",
    );

    system("tidy -m $htmldoc > /dev/null 2>&1");

    mangle_email( $htmldoc );

    my ( $modvol, $moddir, $modname ) = File::Spec->splitpath( $modfile );
    $moddir  =~ s/ [\/\\] \z//xms;
    $modname =~ s/ \.pm \z//xms;
    $modname = join('::', File::Spec->splitdir( $moddir ), $modname);
    push @$modules, [ $modname, File::Spec->abs2rel( $htmldoc, $cwd ) ];
}

sub make_wanted {

    my ( $wanted, @args ) = @_;

    return sub { $wanted->( @args ) };
}

sub generate_html {

    my ( $libdir, $cwd ) = @_;

    $libdir = File::Spec->rel2abs( $libdir );
    $libdir = File::Spec->catdir( $libdir, 'lib' );
    unless ( -d $libdir ) {
        die("Error: Cannot find library directory $libdir.");
    }

    my $modules = [];

    my $wanted = make_wanted( \&base_wanted, $libdir, $cwd, $modules );

    find( $wanted, $libdir );

    return $modules;
}

my ( $topdir, $utildir );

GetOptions(
    "d|topdir=s"  => \$topdir,
    "u|utildir=s" => \$utildir,
);

unless ( $topdir && -d $topdir && $utildir && -d $utildir ) {
    print <<"USAGE";
Usage: $0 -d <top-level model directory> -u <top-level utils directory>
USAGE

    exit 255;
}

my $cwd = getcwd();

my $modules = generate_html( $utildir, $cwd );

my $idx_file = File::Spec->catfile( $cwd, 'index.html' );
printf ( "Creating %s\n", $idx_file );
open( my $index, '>', $idx_file ) or die("Problems opening index file: $!\n");

print $index <<'HEADER';
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Bio::MAGETAB data model</title>
    <link rel="stylesheet" href="../style.css" type="text/css" />
    <meta http-equiv="content-type" content="text/html; charset=us-ascii" />
  </head>
  <body>
    <div class="main">

      <h1>MAGE-TAB Utilities</h1>

      <p class="text">The following modules are used to manipulate the
      data model - the actual MAGE-TAB Utilities. They provide
      parsing, visualization, database loading and export
      functionality:</p>

      <ul>
HEADER

foreach my $mod ( @$modules ) {
    print $index <<"LINK";
      <li><a href="$mod->[1]">$mod->[0]</a></li>
LINK
}

$modules = generate_html( $topdir, $cwd );

print $index <<"UTILHEAD";
      </ul>

      <h1>MAGE-TAB Utilities - Data Model</h1>

      <h2>UML Diagrams</h2>

      <p class="text">PDF diagrams created using MagicDraw 15.1:</p>

      <ul>
        <li><a href="Class_Diagram__MAGE-Tab__adf.pdf">ADF</a></li>
        <li><a href="Class_Diagram__MAGE-Tab__idf.pdf">IDF</a></li>
        <li><a href="Class_Diagram__MAGE-Tab__sdrf.pdf">SDRF</a></li>
      </ul>

      <h2>Perl modules</h2>

      <p class="text">The following modules are used to handle the
      data model used by MAGE-TAB Utilities:</p>

      <ul>
UTILHEAD

foreach my $mod ( @$modules ) {
    print $index <<"LINK";
      <li><a href="$mod->[1]">$mod->[0]</a></li>
LINK
}

print $index <<'FOOTER';
      </ul>
    </div>
    <div>
      <a href="http://sourceforge.net/projects/magetabutils"><img src="http://sflogo.sourceforge.net/sflogo.php?group_id=241102&type=13" width="120" height="30" border="0" alt="Get MAGE-TAB Utilities at SourceForge.net. Fast, secure and Free Open Source software downloads" /></a>
    </div>
  </body>
</html>
FOOTER

