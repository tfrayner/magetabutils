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

package Bio::MAGETAB::Util::Writer::SDRF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

BEGIN { extends 'Bio::MAGETAB::Util::Writer::BaseClass' };

has 'magetab_object'     => ( is         => 'ro',
                              isa        => 'Bio::MAGETAB::SDRF',
                              required   => 1 );

sub _column_heading_from_term {

    my ( $self, $object ) = @_;

    my %dispatch = (
        'MaterialType'    => sub { 'Material Type' },
        'LabelCompound'   => sub { 'Label' },
        'TechnologyType'  => sub { 'Technology Type' },
    );

    my $colname;
    if ( my $sub = $dispatch{ $object->get_category() } ) {
        $colname = $sub->( $object );
    }
    else {
        $colname = sprintf("Characterististics [%s]", $object->get_category() );
    }

    return $colname;
}

sub _column_heading_from_object {

    my ( $self, $object ) = @_;

    my $class = blessed $object;
    $class =~ s/\A Bio::MAGETAB //xms;

    my %dispatch = (
        'Source'              => sub { 'Source Name' },
        'Sample'              => sub { 'Sample Name' },
        'Extract'             => sub { 'Extract Name' },
        'LabeledExtract'      => sub { 'Labeled Extract Name' },
        'Assay'               => sub { $_[0]->get_technologyType() eq 'hybridization'
                                           ? 'Hybridization Name'
                                           : 'Assay Name' },
        'DataAcquisition'     => sub { 'Scan Name' },
        'Normalization'       => sub { 'Normalization Name' },
        'DataFile'            => sub { $_[0]->get_type() eq 'image' ? 'Image File'
                                           : 'raw' ? 'Array Data File'
                                           : 'Derived Array Data File' },
        'DataMatrix'          => sub { $_[0]->get_type() eq 'raw'
                                           ? 'Array Data Matrix File'
                                           : 'Derived Array Data Matrix File' },
        'ProtocolApplication' => sub { 'Protocol REF' },
        'ControlledTerm'      => sub { $self->_column_heading_from_term( @_ ) },
    );

    my $col_sub;
    unless ( $col_sub = $dispatch{ $class } ) {
        confess(qq{Error: Class "$class" is not mapped to a column heading.});
    }

    return $col_sub->( $object );
}

sub write {

    my ( $self ) = @_;

    my $fh   = $self->get_filehandle();
    my $sdrf = $self->get_magetab_object();

    # Quick Schwarzian transform to list the rows in order, longest first.
    my @sorted_rows = map { $_->[1] }
                      reverse sort { $a->[0] <=> $b->[0] }
                      map { [ scalar $_->get_nodes(), $_ ] } $sdrf->get_sdrfRows();
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
