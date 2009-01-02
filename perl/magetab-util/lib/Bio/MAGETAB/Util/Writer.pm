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

package Bio::MAGETAB::Util::Writer;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

use Bio::MAGETAB::Util::Writer::IDF;
use Bio::MAGETAB::Util::Writer::ADF;
use Bio::MAGETAB::Util::Writer::SDRF;

has 'magetab'            => ( is         => 'rw',
                              isa        => 'Bio::MAGETAB',
                              required   => 1 );

sub write {

    my ( $self ) = @_;

    my $magetab = $self->get_magetab();
    foreach my $investigation ( $self->get_investigations() ) {
        my $filename = $self->_sanitize_path( $investigation->get_title() );

        open( my $fh, '>', $filename )
            or croak("Error: Unable to open IDF output file: $!");

        my $writer = Bio::MAGETAB::Util::Writer::IDF->new(
            magetab_object => $investigation,
            filehandle     => $fh,
        );

        $writer->write();
    }
    foreach my $array ( $self->get_arrayDesigns() ) {
        my $filename;
        if ( my $uri = $array->uri() ) {
            my $path = $uri->path();
            ( $filename ) = ( $path =~ m/([^\/]+) \z/xms );
        }
        unless ( $filename ) {
            $filename = $self->_sanitize_path( $array->name() );
        }

        open( my $fh, '>', $filename )
            or croak("Error: Unable to open ADF output file: $!");
        my $writer = Bio::MAGETAB::Util::Writer::ADF->new(
            magetab_object => $array,
            filehandle     => $fh,
        );

        $writer->write();
    }
    foreach my $sdrf ( $self->get_sdrfs() ) {
        my $path = $sdrf->uri()->path();
        my ( $filename ) = ( $path =~ m/([^\/]+) \z/xms );
        
        open( my $fh, '>', $filename )
            or croak("Error: Unable to open SDRF output file: $!");
        my $writer = Bio::MAGETAB::Util::Writer::SDRF->new(
            magetab_object => $sdrf,
            filehandle     => $fh,
        );

        $writer->write();
    }

    return;
}

sub _sanitize_path {

    my ( $self, $path ) = @_;

    # Sanitize the file name.
    $path =~ s/[^A-Za-z0-9_-]+/_/g;

    return $path;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=head1 NAME

Bio::MAGETAB::Util::Writer - Export of MAGE-TAB objects.

=head1 SYNOPSIS

 use Bio::MAGETAB::Util::Writer;
 my $writer = Bio::MAGETAB::Util::Writer->new({
    magetab => $magetab_container,
 });
 
 $writer->write();

=head1 DESCRIPTION

This class is designed to export all the MAGE-TAB objects from a given
Bio::MAGETAB container, creating as many IDFs, ADFs and SDRFs as are
necessary to do so. **NOTE** that this module is not yet fully
implemented or tested, although the API should remain unchanged.

Export of the individual MAGE-TAB components is delegated to separate
writer classes. See L<Bio::MAGETAB::Util::Writer::ADF>,
L<Bio::MAGETAB::Util::Writer::IDF> and
L<Bio::MAGETAB::Util::Writer::SDRF> if you want more control over the
export process.

=head1 ATTRIBUTES

=over 2

=item magetab

The Bio::MAGETAB container to export. This is a required
attribute. See L<Bio::MAGETAB> for more information on this container
class.

=back

=head1 METHODS

=over 2

=item write

Exports all objects into their respective MAGE-TAB
components. Filenames are automatically generated from Investigation
title, ArrayDesign uri (or name) and SDRF uri attributes.

=back

=head1 SEE ALSO

L<Bio::MAGETAB>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
