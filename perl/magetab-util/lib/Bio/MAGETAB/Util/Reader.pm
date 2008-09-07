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

package Bio::MAGETAB::Util::Reader;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::Types qw(Uri);

use Carp;

use Bio::MAGETAB::Util::Reader::ADF;
use Bio::MAGETAB::Util::Reader::IDF;
use Bio::MAGETAB::Util::Reader::SDRF;
use Bio::MAGETAB::Util::Reader::Builder;

has 'idf'                 => ( is         => 'rw',
                               isa        => 'Uri',
                               required   => 1,
                               coerce     => 1 );

has 'authority'           => ( is         => 'rw',
                               isa        => 'Str',
                               default    => q{},
                               required   => 1 );

has 'namespace'           => ( is         => 'rw',
                               isa        => 'Str',
                               default    => q{},
                               required   => 1 );

has 'relaxed_parser'      => ( is         => 'rw',
                               isa        => 'Bool',
                               default    => 0,
                               required   => 1 );

# Make this visible to users of the module.
our $VERSION = 0.1;

sub parse {

    my ( $self ) = @_;

    # We use this object to track MAGETAB object creation.
    my $builder = Bio::MAGETAB::Util::Reader::Builder->new(
        namespace      => $self->get_namespace(),
        authority      => $self->get_authority(),
        relaxed_parser => $self->get_relaxed_parser(),
    );

    my $idf_parser = Bio::MAGETAB::Util::Reader::IDF->new({
	uri     => $self->get_idf(),
        builder => $builder,
    });

    my ( $investigation, $magetab_container ) = $idf_parser->parse();

    # FIXME parse the SDRFS etc. here. N.B. some extra stitching may be needed.
    foreach my $sdrf ( @{ $investigation->get_sdrfs() } ) {

        # FIXME rewrite the SDRF URI according to our IDF URI?

        # FIXME consider optionally passing in a Bio::MAGETAB::SDRF
        # object here, so the SDRF parser API could make a little more
        # sense.
	my $sdrf_parser = Bio::MAGETAB::Util::Reader::SDRF->new({
	    uri                        => $sdrf->get_uri(),
            builder                    => $builder,
            magetab_object             => $sdrf,
	});

        my $sdrf = $sdrf_parser->parse();
    }

    # Parse through all the DataMatrix objects.
    foreach my $matrix ( $magetab_container->get_DataMatrices() ) {
        my $parser = Bio::MAGETAB::Util::Reader::DataMatrix->new({
            uri            => $matrix->get_uri(),
            builder        => $builder,           
            magetab_object => $matrix,
        });

        $parser->parse();
    }

    # Parse through all the ADFs.
    foreach my $array ( $magetab_container->get_ArrayDesigns() ) {
        if ( $array->get_uri() ) {
            my $parser = Bio::MAGETAB::Util::Reader::ADF->new({
                uri            => $array->get_uri(),
                builder        => $builder,           
                magetab_object => $array,
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

1;
