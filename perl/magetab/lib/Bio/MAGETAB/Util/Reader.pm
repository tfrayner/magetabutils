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

package Bio::MAGETAB::Util::Reader;

use 5.008001;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use MooseX::Types::Moose qw( Str Bool );
use Bio::MAGETAB::Types qw( Uri );

use Carp;

use Bio::MAGETAB::Util::Reader::ADF;
use Bio::MAGETAB::Util::Reader::IDF;
use Bio::MAGETAB::Util::Reader::SDRF;
use Bio::MAGETAB::Util::Reader::DataMatrix;
use Bio::MAGETAB::Util::Builder;

has 'idf'                 => ( is         => 'rw',
                               isa        => Uri,
                               required   => 1,
                               coerce     => 1 );

has 'authority'           => ( is         => 'rw',
                               isa        => Str,
                               default    => q{},
                               required   => 1 );

has 'namespace'           => ( is         => 'rw',
                               isa        => Str,
                               default    => q{},
                               required   => 1 );

has 'relaxed_parser'      => ( is         => 'rw',
                               isa        => Bool,
                               default    => 0,
                               required   => 1 );

has 'ignore_datafiles'    => ( is         => 'rw',
                               isa        => Bool,
                               default    => 0,
                               required   => 1 );

has 'builder'             => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Util::Builder',
                               default    => sub { Bio::MAGETAB::Util::Builder->new() },
                               required   => 1 );

# Make this visible to users of the module.
our $VERSION = 0.4;

sub parse {

    my ( $self ) = @_;

    # We use this object to track MAGETAB object creation.
    my $builder = $self->get_builder();
    $builder->set_namespace(      $self->get_namespace()      );
    $builder->set_authority(      $self->get_authority()      );
    $builder->set_relaxed_parser( $self->get_relaxed_parser() );

    my $idf_parser = Bio::MAGETAB::Util::Reader::IDF->new({
	uri     => $self->get_idf(),
        builder => $builder,
    });

    my ( $investigation, $magetab_container ) = $idf_parser->parse();

    # FIXME parse the SDRFS etc. here. N.B. some extra stitching may be needed.
    foreach my $sdrf ( @{ $investigation->get_sdrfs() } ) {

        # FIXME rewrite the SDRF URI according to our IDF URI?

	my $sdrf_parser = Bio::MAGETAB::Util::Reader::SDRF->new({
	    uri                        => $sdrf->get_uri(),
            builder                    => $builder,
            magetab_object             => $sdrf,
	});

        my $sdrf = $sdrf_parser->parse();
    }

    # Parse through all the ADFs.
    foreach my $array ( $magetab_container->get_arrayDesigns() ) {
        if ( $array->get_uri() ) {
            my $parser = Bio::MAGETAB::Util::Reader::ADF->new({
                uri            => $array->get_uri(),
                builder        => $builder,           
                magetab_object => $array,
            });
            $parser->parse();
        }
    }

    # Parse through all the DataMatrix objects.
    unless ( $self->get_ignore_datafiles() ) {
        foreach my $matrix ( $magetab_container->get_dataMatrices() ) {
            my $parser = Bio::MAGETAB::Util::Reader::DataMatrix->new({
                uri            => $matrix->get_uri(),
                builder        => $builder,           
                magetab_object => $matrix,
            });

            $parser->parse();
        }
    }

    return wantarray
	   ? ( $investigation, $magetab_container )
	   : $magetab_container;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=head1 NAME

Bio::MAGETAB::Util::Reader - A parser/validator for MAGE-TAB documents.

=head1 SYNOPSIS

 use Bio::MAGETAB::Util::Reader;
 my $reader = Bio::MAGETAB::Util::Reader->new({
    idf            => $idf,
    relaxed_parser => $is_relaxed,
 });

 my $magetab = $reader->parse();

=head1 DESCRIPTION

This is the main parsing and validation class which can be used to
read a MAGE-TAB document into a set of Bio::MAGETAB classes for
further manipulation.

=head1 ATTRIBUTES

=over 2

=item idf

A filesystem or URI path to the top-level IDF file describing the
investigation. This attribute is *required*.

=item relaxed_parser

A boolean value (default FALSE) indicating whether or not the parse
should take place in "relaxed mode" or not. The regular parsing mode
will throw an exception in cases where an object is referenced before
it has been declared (e.g., Protocol REF pointing to a non-existent
Protocol Name). Relaxed parsing mode will silently autogenerate the
non-existent objects instead.

=item namespace

An optional namespace string to be used in object creation.

=item authority

An optional authority string to be used in object creation.

=item builder

An optional Builder object. These Builder objects are used to track
the creation of Bio::MAGETAB objects by caching the objects in an
internal store, keyed by a set of identifying information (see
L<Bio::MAGETAB::Util::Builder>). This object can be used in
multiple Reader objects to help link common objects from multiple
MAGE-TAB documents together. In its simplest form this internal store
is a simple hash; however in principle this could be extended by
subclassing Builder to create e.g. persistent database storage
mechanisms.

=back

=head1 METHODS

=over 2

=item parse

Attempts to parse the full MAGE-TAB document, starting with the
top-level IDF file, and returns the resulting Bio::MAGETAB container
object in scalar context, or the top-level Bio::MAGETAB::Investigation
object and container object in list context.

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
