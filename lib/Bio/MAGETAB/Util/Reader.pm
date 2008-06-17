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

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::Types qw(Uri);

use Carp;

use Bio::MAGETAB::Util::Reader::IDF;
use Bio::MAGETAB::Util::Reader::SDRF;
use Bio::MAGETAB::Util::Reader::Builder;

has 'idf'                 => ( is         => 'rw',
                               isa        => 'Uri',
                               required   => 1 );

has 'authority'           => ( is         => 'rw',
                               isa        => 'Str',
                               default    => q{},
                               required   => 1 );

has 'namespace'           => ( is         => 'rw',
                               isa        => 'Str',
                               default    => q{},
                               required   => 1 );

#my %clobber           : ATTR( :name<clobber>, :default<0>  );
#my %target_directory     : ATTR( :name<target_directory>,   :init_arg<target_directory>, );
#my %source_directory     : ATTR( :get<source_directory>,    :init_arg<source_directory>,    :default<undef> );
#my %is_standalone        : ATTR( :get<is_standalone>,       :init_arg<is_standalone>,       :default<0> );
my %skip_datafiles       : ATTR( :get<skip_datafiles>,      :init_arg<skip_datafiles>,      :default<undef> );
#my %in_relaxed_mode      : ATTR( :name<in_relaxed_mode>,    :default<0> );
#my %ignore_size_limits   : ATTR( :name<ignore_size_limits>, :default<undef> );

# Make this visible to users of the module.
our $VERSION = 0.1;

sub parse {

    my ( $self ) = @_;

    $self->logprint('magetab',
		    sprintf("Processing IDF: %s\n\n", $self->get_idf()));

    # We use this object to track MAGETAB object creation.
    my $builder = Bio::MAGETAB::Util::Reader::Builder->new(
        namespace => $self->get_namespace(),
        authority => $self->get_authority(),
    );

    my $idf_parser = Bio::MAGETAB::Util::Reader::IDF->new({
	uri     => $self->get_idf(),
        builder => $builder,
    });

    my ( $investigation, $magetab_container ) = $idf_parser->parse();

    my $sdrfs = $investigation->get_SDRFs();

    # FIXME parse the SDRFS etc. here
    foreach my $sdrf_file (@$sdrfs) {

	# FIXME stitch the SDRFs together here. NB is this actually needed in the new MAGETAB world?

    }

    if ( scalar @$sdrfs ) {

	# FIXME only one SDRF supported for now:
	my $sdrf_file = $sdrfs->[0];  # FIXME delete this line when ready.

        # FIXME rewrite the SDRF URI according to our IDF URI.

	$self->logprint('magetab',
			sprintf("Processing SDRF: %s\n\n", $sdrf_file));

	my $sdrf_parser = ArrayExpress::MAGETAB::SDRF->new({
	    uri                        => $sdrf_file,
            builder                    => $builder,
            container                  => $magetab_container,    # for BaseClass->set_ClassContainer
#	    skip_datafiles             => $self->get_skip_datafiles(),
	});

        my $sdrf_rows = $sdrf_parser->parse();

        $sdrf->set_sdrfRows( $sdrf_rows );
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
