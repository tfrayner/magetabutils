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

package Bio::MAGETAB::Util::Reader::IDF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;
use List::Util qw(first);

BEGIN { extends 'Bio::MAGETAB::Util::Reader::TagValueFile' };

# FIXME consider having a magetab_object attribute (maybe linked to
# Investigation?) here for consistency. Not as important for IDF,
# which never knows about its own uri.

sub BUILD {

    my ( $self, $params ) = @_;

    # Dispatch table to direct each field to the appropriate place in
    # the text_store hashref. First argument is the internal tag used
    # to group the fields into concepts, the second is the
    # Bio::MAGETAB attribute name for the object.
    my $dispatch = {
        qr/Investigation *Title/i
            => sub{ $self->_add_singleton_datum('investigation', 'title',          @_) },
        qr/Date *Of *Experiment/i
            => sub{ $self->_add_singleton_datum('investigation', 'date',           @_) },
        qr/Public *Release *Date/i
            => sub{ $self->_add_singleton_datum('investigation', 'publicReleaseDate', @_) },
        qr/Experiment *Description/i
            => sub{ $self->_add_singleton_datum('investigation', 'description',    @_) },
        qr/SDRF *Files?/i
            => sub{ $self->_add_singleton_data('investigation', 'sdrfs',   @_) },

        qr/Experimental *Factor *Names?/i
            => sub{ $self->_add_grouped_data('factor', 'name',       @_) },
        qr/Experimental *Factor *Types?/i
            => sub{ $self->_add_grouped_data('factor', 'type',       @_) },
        qr/Experimental *Factor *(?:Types?)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('factor', 'termSource', @_) },
        qr/Experimental *Factor *(?:Types?)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('factor', 'accession',  @_) },

        qr/Person *Last *Names?/i
            => sub{ $self->_add_grouped_data('person', 'lastName',    @_) },
        qr/Person *First *Names?/i
            => sub{ $self->_add_grouped_data('person', 'firstName',   @_) },
        qr/Person *Mid *Initials?/i
            => sub{ $self->_add_grouped_data('person', 'midInitials', @_) },
        qr/Person *Emails?/i
            => sub{ $self->_add_grouped_data('person', 'email',       @_) },
        qr/Person *Phones?/i
            => sub{ $self->_add_grouped_data('person', 'phone',       @_) },
        qr/Person *Fax(es)?/i
            => sub{ $self->_add_grouped_data('person', 'fax',         @_) },
        qr/Person *Address(es)?/i
            => sub{ $self->_add_grouped_data('person', 'address',     @_) },
        qr/Person *Affiliations?/i
            => sub{ $self->_add_grouped_data('person', 'organization', @_) },
        qr/Person *Roles?/i
            => sub{ $self->_add_grouped_data('person', 'roles',       @_) },
        qr/Person *Roles? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('person', 'termSource',  @_) },
        qr/Person *Roles? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('person', 'accession',  @_) },

        qr/Experimental *Designs?/i
            => sub{ $self->_add_grouped_data('design', 'value',     @_) },
        qr/Experimental *Designs? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('design', 'termSource', @_) },
        qr/Experimental *Designs? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('design', 'accession', @_) },
        qr/Quality *Control *Types?/i
            => sub{ $self->_add_grouped_data('qualitycontrol', 'value',       @_) },
        qr/Quality *Control *(?:Types?)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('qualitycontrol', 'termSource', @_) },
        qr/Quality *Control *(?:Types?)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('qualitycontrol', 'accession', @_) },
        qr/Replicate *Types?/i
            => sub{ $self->_add_grouped_data('replicate',      'value',       @_) },
        qr/Replicate *(?:Types?)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('replicate',      'termSource', @_) },
        qr/Replicate *(?:Types?)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('replicate',      'accession', @_) },
        qr/Normali[sz]ation *Types?/i
            => sub{ $self->_add_grouped_data('normalization',  'value',       @_) },
        qr/Normali[sz]ation *(?:Types?)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('normalization',  'termSource', @_) },
        qr/Normali[sz]ation *(?:Types?)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('normalization',  'accession', @_) },
 
        qr/PubMed *IDs?/i
            => sub{ $self->_add_grouped_data('publication', 'pubmedid',   @_) },
        qr/Publication *DOIs?/i
            => sub{ $self->_add_grouped_data('publication', 'doi',        @_) },
        qr/Publication *Authors? *Lists?/i
            => sub{ $self->_add_grouped_data('publication', 'authorlist', @_) },
        qr/Publication *Titles?/i
            => sub{ $self->_add_grouped_data('publication', 'title',      @_) },
        qr/Publication *Status/i
            => sub{ $self->_add_grouped_data('publication', 'status',     @_) },
        qr/Publication *Status *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('publication', 'termSource', @_) },
        qr/Publication *Status *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('publication', 'accession', @_) },

        qr/Protocol *Names?/i
            => sub{ $self->_add_grouped_data('protocol', 'name',        @_) },
        qr/Protocol *Descriptions?/i
            => sub{ $self->_add_grouped_data('protocol', 'text', @_) },
        qr/Protocol *Parameters?/i
            => sub{ $self->_add_grouped_data('protocol', 'parameters',  @_) },
        qr/Protocol *Hardwares?/i
            => sub{ $self->_add_grouped_data('protocol', 'hardware',    @_) },
        qr/Protocol *Softwares?/i
        => sub{ $self->_add_grouped_data('protocol', 'software',    @_) },
        qr/Protocol *Contacts?/i
            => sub{ $self->_add_grouped_data('protocol', 'contact',     @_) },
        qr/Protocol *Types?/i
            => sub{ $self->_add_grouped_data('protocol', 'type',        @_) },
        qr/Protocol *(?:Types?)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('protocol', 'termSource',  @_) },
        qr/Protocol *(?:Types?)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('protocol', 'accession',  @_) },

        qr/Term *Source *Names?/i
            => sub{ $self->_add_grouped_data('termsource', 'name',     @_) },
        qr/Term *Source *Files?/i
            => sub{ $self->_add_grouped_data('termsource', 'uri',      @_) },
        qr/Term *Source *Versions?/i
            => sub{ $self->_add_grouped_data('termsource', 'version',  @_) },
    };

    $self->set_dispatch_table( $dispatch );

    return;
}

##################
# Public methods #
##################

sub parse {

    my ( $self ) = @_;

    # Parse the IDF file into memory here.
    my $array_of_rows = $self->_read_as_arrayref();

    # Check tags for duplicates, make sure that tags are recognized.
    my $idf_hash = $self->_validate_arrayref_tags( $array_of_rows );

    # Populate the IDF object's internal data text_store attribute.
    while ( my ( $tag, $values ) = each %$idf_hash ) {
	$self->_dispatch( $tag, @$values );
    }

    # Actually generate the Bio::MAGETAB objects.
    my ( $investigation, $magetab ) = $self->_generate_magetab();

    return ( $investigation, $magetab );
}

###################
# Private methods #
###################

sub _generate_magetab {

    my ( $self ) = @_;

    my $magetab       = $self->get_builder()->get_magetab();
    my $investigation = $self->_create_investigation();

    return ( $investigation, $magetab );
}

sub _create_factors {

    my ( $self ) = @_;

    my @factors;
    foreach my $f_data ( @{ $self->get_text_store()->{ 'factor' } } ) {

        my $termsource;
        if ( my $ts = $f_data->{'termSource'} ) {
            $termsource = $self->get_builder()->get_term_source({
                'name' => $ts,
            });
        }

        my $type = $self->get_builder()->find_or_create_controlled_term({
            'category'   => 'ExperimentalFactorCategory',
            'value'      => $f_data->{'type'},
            'accession'  => $f_data->{'accession'},
            'termSource' => $termsource,
        });

        my $args = {
            'name' => $f_data->{'name'},
            'type' => $type,
        };

        my $factor = $self->get_builder()->find_or_create_factor( $args );

	push @factors, $factor;
    }

    return \@factors;
}

sub _create_people {

    my ( $self ) = @_;

    my @people;
    foreach my $p_data ( @{ $self->get_text_store()->{ 'person' } } ) {

        my $termsource;
        if ( my $ts = $p_data->{'termSource'} ) {
            $termsource = $self->get_builder()->get_term_source({
                'name' => $ts,
            });
        }

        my $roles = map {
            $self->get_builder()->find_or_create_controlled_term({
                'category'   => 'Roles',
                'value'      => $_,
                'accession'  => $p_data->{'accession'},
                'termSource' => $termsource,
            });
        } split /\s*;\s*/, $p_data->{'roles'};

        my @wanted = grep { $_ !~ /^roles|termSource|accession$/ } keys %{ $p_data };
        my %args   = map { $_ => $p_data->{$_} } @wanted;
        $args{'roles'} = $roles;

        my $person = $self->get_builder()->find_or_create_contact( \%args );

	push @people, $person;
    }

    return \@people;
}

sub _create_protocols {

    my ( $self ) = @_;

    my @protocols;
    foreach my $p_data ( @{ $self->get_text_store()->{ 'protocol' } } ) {

        my $termsource;
        if ( my $ts = $p_data->{'termSource'} ) {
            $termsource = $self->get_builder()->get_term_source({
                'name' => $ts,
            });
        }

        my $type = $self->get_builder()->find_or_create_controlled_term({
            'category'   => 'ProtocolType',
            'value'      => $p_data->{'type'},
            'accession'  => $p_data->{'accession'},
            'termSource' => $termsource,
        });

        my @wanted = grep { $_ !~ /^parameters|type|termSource|accession$/ } keys %{ $p_data };
        my %args   = map { $_ => $p_data->{$_} } @wanted;
        $args{'type'} = $type;

        my $protocol = $self->get_builder()->find_or_create_protocol( \%args );

        my $parameters = map {
            $self->get_builder()->find_or_create_protocol_parameter({
                'name'       => $_,
                'protocol'   => $protocol,
            });
        } split /\s*;\s*/, $p_data->{'parameters'};

	push @protocols, $protocol;
    }

    return \@protocols;
}

sub _create_publications {

    my ( $self ) = @_;

    my @publications;
    foreach my $p_data ( @{ $self->get_text_store()->{ 'publication' } } ) {

        my $termsource;
        if ( my $ts = $p_data->{'termSource'} ) {
            $termsource = $self->get_builder()->get_term_source({
                'name' => $ts,
            });
        }

        my $status = $self->get_builder()->find_or_create_controlled_term({
            'category'   => 'PublicationStatus',
            'value'      => $p_data->{'status'},
            'accession'  => $p_data->{'accession'},
            'termSource' => $termsource,
        });

        my @wanted = grep { $_ !~ /^status|termSource|accession$/ } keys %{ $p_data };
        my %args   = map { $_ => $p_data->{$_} } @wanted;
        $args{'status'} = $status;

        my $publication = $self->get_builder()->find_or_create_publication( \%args );

	push @publications, $publication;
    }

    return \@publications;
}

sub _create_investigation {

    my ( $self ) = @_;

    # Term Sources. These must be created first.
    my $term_sources = $self->_create_termsources();

    my $factors      = $self->_create_factors();
    my $people       = $self->_create_people();
    my $protocols    = $self->_create_protocols();
    my $publications = $self->_create_publications();

    my $design_types        = $self->_create_controlled_terms(
        'design',         'ExperimentDesignType',
    );
    my $normalization_types = $self->_create_controlled_terms(
        'normalization',  'NormalizationDescriptionType',
    );
    my $replicate_types     = $self->_create_controlled_terms(
        'replicate',      'ReplicateDescriptionType',
    );
    my $qc_types            = $self->_create_controlled_terms(
        'qualitycontrol', 'QualityControlDescriptionType',
    );

    my $data = $self->get_text_store()->{'investigation'};
    
    my $investigation = $self->get_builder()->find_or_create_investigation({
        %{ $data },
        'contacts'            => $people,
        'protocols'           => $protocols,
        'publications'        => $publications,
        'factors'             => $factors,
        'termSources'         => $term_sources,
        'designTypes'         => $design_types,
        'normalizationTypes'  => $normalization_types,
        'replicateTypes'      => $replicate_types,
        'qualityControlTypes' => $qc_types,
    });

    my $comments = $self->_create_comments();
    $investigation->set_comments( $comments );

    return $investigation;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
