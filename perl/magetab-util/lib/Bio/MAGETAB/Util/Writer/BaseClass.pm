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

package Bio::MAGETAB::Util::Writer::BaseClass;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;
use Text::CSV_XS;

has 'filehandle'         => ( is         => 'rw',
                              isa        => 'FileHandle',
                              coerce     => 1,
                              required   => 1 );

has 'num_columns'        => ( is         => 'rw',
                              isa        => 'Int',
                              required   => 0 );

has 'csv_writer'         => ( is         => 'rw',
                              isa        => 'Text::CSV_XS',
                              required   => 0 );

sub _write_line {

    my ( $self, $field, @values ) = @_;

    my $fh = $self->get_filehandle();

    my $num_cols = $self->get_num_columns()
        or confess("Error: Number of columns has not yet been calculated.");

    my $csv_writer = $self->_construct_csv_writer();

    # Replace any undefined values with empty string.
    @values = map { defined $_ ? $_ : q{} } @values;

    # Check we're not out of bounds.
    my @to_write = ( $field, @values );
    if ( scalar @to_write > $num_cols ) {
        confess("Error: Attempted to write more columns than were originally calculated.");
    }

    # Pad the line with empty strings.
    my $diff = $num_cols - scalar @to_write;
    push @to_write, (q{}) x $diff;

    # Write the line.
    $csv_writer->print( $fh, \@to_write );

    return;
}

sub _construct_csv_writer {

    my ( $self ) = @_;

    # We cache this in a private attribute so each file only gets one
    # writer (better for error trackage).
    unless ( $self->get_csv_writer() ) {
        my $csv_writer = Text::CSV_XS->new(
            {   sep_char    => qq{\t},
                quote_char  => qq{"},                   # default
                escape_char => qq{"},                   # default
                binary      => 1,
                eol         => qq{\n},
            }
        );
        $self->set_csv_writer( $csv_writer );
    }

    return $self->get_csv_writer();
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;