#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

use Bio::MAGETAB::Util::DBIC::DB;
use Bio::MAGETAB::Util::DBIC::Loader;
use Bio::MAGETAB::Util::Reader;

use Data::Dumper;

sub parse_args {

    my ( $dbname, $idf, $want_help );

    GetOptions(
        "i|idf=s"      => \$idf,
        "d|database=s" => \$dbname,
        "h|help"       => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $dbname && $idf ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    return( $dbname, $idf );
}

my ( $dbname, $idf ) = parse_args();

my $schema  = Bio::MAGETAB::Util::DBIC::DB->connect("dbi:mysql:$dbname");
my $builder = Bio::MAGETAB::Util::DBIC::Loader->new(database => $schema);
my $reader  = Bio::MAGETAB::Util::Reader->new(builder => $builder,
                                              idf     => $idf);

$reader->parse();

__END__

=head1 NAME

testing.pl

=head1 SYNOPSIS

 testing.pl -d magetab-db -i idf

=head1 DESCRIPTION

Stub documentation for testing.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

Probably.

=cut
