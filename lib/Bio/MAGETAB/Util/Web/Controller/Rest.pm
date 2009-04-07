#!/usr/bin/env perl
#
# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB::Util::Web.
# 
# Bio::MAGETAB::Util::Web is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB::Util::Web is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB::Util::Web.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package Bio::MAGETAB::Util::Web::Controller::Rest;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';

use Scalar::Util qw( blessed );
use Carp;

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::Rest - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller supporting RESTful database access.

=head1 METHODS

=cut

sub object_by_oid : Local : ActionClass('REST') {}

sub object_by_oid_GET {

    my ( $self, $c, $oid ) = @_;

    my $object;
    eval {

        # Dies if not found.
        $object = $c->model()->storage()->load( $oid );
    };

    if ( $object && ! $@ ) {

        my $data;
        eval {
            $data = $self->_summarize_object( $c, $object, 2 );
        };

        if ( $data && ! $@ ) {
            $self->status_ok(
                $c,
                entity => $data,
            );
        }
        else {

            my $class = blessed $object;
            $self->status_bad_request(
                $c,
                message => "Unable to summarize $class objects: $@",
            );
        }
    }
    else {
        $self->status_not_found(
            $c,
            message => "Object with OID $oid not found",
        );
    }
}

sub investigation : Local : ActionClass('REST') {}

sub investigation_GET {

    my ( $self, $c, $query ) = @_;

    my $remote  = $c->model()->storage()
                    ->remote( "Bio::MAGETAB::Investigation" );

    # FIXME we will undoubtedly want to expand this query further.
    my @objects = $c->model()->storage()
                    ->select( $remote, $remote->{title}      ->like("%${query}%")
                                     | $remote->{description}->like("%${query}%") );

    if ( scalar @objects ) {
        my @data;
        foreach my $obj ( @objects ) {
            push @data, $self->_summarize_investigation( $c, $obj );
        }

        $self->status_ok(
            $c,
            entity => \@data,
        );
    }
    else {
        $self->status_not_found(
            $c,
            message => qq{No Investigations found for "$query"},
        );
    }
}

#
# Methods used to sanitize objects before serialisation.
#

sub _summarize_object : Private {

    my ( $self, $c, $obj, $depth_wanted, $class ) = @_;

    my $namespace = 'Bio::MAGETAB';

    $class ||= blessed $obj;
    my $method  = $self->_summary_method( $class );
    if ( UNIVERSAL::can( $self, $method ) ) {

        # Return a full serialization. Summarize superclass
        # attributes recursively here. 
        my $data = {};
        CLASS:
        foreach my $super ( $class->meta()->superclasses() ) {

            # Don't follow superclasses outside the Bio::MAGETAB
            # namespace.
            next CLASS unless $super =~ /^${namespace}/;

            # Summarize information from the superclass.
            my $newdata = $self->_summarize_object( $c, $obj, $depth_wanted, $super );
            @{ $data }{keys %$newdata} = values %$newdata;
        }

        # Rather than dump everything for every object from
        # e.g. Investigation on down, we use this $depth_wanted variable to
        # track how far down in the heirarchy we want to descend. We
        # decrement after processing the superclasses.
        $depth_wanted-- if $depth_wanted;

        # Get information from this class.
        my $newdata = $self->$method( $c, $obj, $depth_wanted );
        @{ $data }{keys %$newdata} = values %$newdata;

        # Set some standard attributes.
        $data->{oid} = $c->model()->storage()->id( $obj );
        $class =~ s/^${namespace}:://;
        $data->{class} = $class;

        # And we're done.
        return $data;
    }
    else {

        # This should be caught in an eval.
        die(qq{Error: Unknown summary method "$method"\n});
    }
}

# Individual class summarization methods. Within each method, only the
# immediate attributes of each class need to be considered. Each
# method should have two levels of verbosity: when $depth_wanted evaluates
# true or not.

sub _summarize_base_class : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    return {} unless $depth_wanted;

    my %data = (
        authority => $obj->get_authority(),
        namespace => $obj->get_namespace(),
    );

    return \%data;    
}
           
sub _summarize_investigation : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        title             => $obj->get_title(),
        description       => $obj->get_description(),
        date              => $obj->get_date(),
        publicReleaseDate => $obj->get_publicReleaseDate(),
    );

    return \%data unless $depth_wanted;

    my @factors;
    foreach my $factor ( $obj->get_factors() ) {
        push @factors, $self->_summarize_object( $c, $factor, $depth_wanted );
    }
    $data{factors} = \@factors;

    my @sdrfs;
    foreach my $sdrf ( $obj->get_sdrfs() ) {
        push @sdrfs, $self->_summarize_object( $c, $sdrf, $depth_wanted );
    }
    $data{sdrfs} = \@sdrfs;

    return \%data;
}

sub _summarize_sdrf : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        uri               => $obj->get_uri(),
    );

    return \%data unless $depth_wanted;

    my @sdrfrows;
    foreach my $row ( $obj->get_sdrfRows() ) {
        push @sdrfrows, $self->_summarize_object( $c, $row, $depth_wanted );
    }
    $data{sdrfRows} = \@sdrfrows;

    return \%data;
}

sub _summarize_factor : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        name              => $obj->get_name(),
        factorType        => $self->_summarize_object(
                                         $c, $obj->get_factorType(), $depth_wanted ),
    );

    return \%data;
}

sub _summarize_factor_value : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        factor            => $self->_summarize_object(
                                         $c, $obj->get_factor(), $depth_wanted ),
    );
    if ( my $term = $obj->get_term() ) {
        $data{term} = $self->_summarize_object(
            $c, $obj->get_term(), $depth_wanted );
    }
    if ( my $meas = $obj->get_measurement() ) {
        $data{measurement} = $self->_summarize_object(
            $c, $obj->get_measurement(), $depth_wanted );
    }

    return \%data;
}

sub _summarize_sdrfrow : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        rowNumber         => $obj->get_rowNumber(),
        channel           => $self->_summarize_object(
                                         $c, $obj->get_channel(), $depth_wanted ),
    );

    return \%data unless $depth_wanted;

    my @nodedata;
    foreach my $node ( $obj->get_nodes() ) {
        push @nodedata, $self->_summarize_object( $c, $node, $depth_wanted );
    }

    $data{nodes} = \@nodedata;

    return \%data;
}

sub _summarize_node : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data;

    my @commentdata;
    foreach my $comment ( $obj->get_comments() ) {
        push @commentdata, $self->_summarize_object( $c, $comment, $depth_wanted );
    }
    $data{comments} = \@commentdata;

    # Note that we only go one way here; handling outputEdges might
    # result in a race condition. Note also that we're omitting
    # sdrfRows for the same reason.
    my @inputedgedata;
    foreach my $input ( $obj->get_inputEdges() ) {
        push @inputedgedata, $self->_summarize_object( $c, $input, $depth_wanted );
    }
    $data{inputEdges} = \@inputedgedata;

    my $class = blessed $obj;
    my $method = $self->_summary_method( $class );
    if ( UNIVERSAL::can( $self, $method ) ) {
        my %subdata = $self->$method( $c, $obj, $depth_wanted );
        @data{ keys %subdata } = values %subdata;
    }

    return \%data;
}

sub _summarize_data_file : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        uri               => $obj->get_uri(),
        format            => $self->_summarize_object(
                                         $c, $obj->get_format(), $depth_wanted ),
        dataType          => $self->_summarize_object(
                                         $c, $obj->get_dataType(), $depth_wanted ),
    );    

    return \%data;
}

sub _summarize_measurement : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        measurementType   => $obj->get_measurementType(),
        value             => $obj->get_value(),
        min_value         => $obj->get_min_value(),
        max_value         => $obj->get_max_value(),
        unit              => $self->_summarize_object(
                                         $c, $obj->get_unit(), $depth_wanted ),
    );

    return \%data unless $depth_wanted;

    # FIXME Anything here?.
    return \%data;
}

sub _summarize_database_entry : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        accession         => $obj->get_accession(),
    );

    return \%data unless $depth_wanted;

    # FIXME TermSource etc.
    return \%data;
}

sub _summarize_controlled_term : Private {

    my ( $self, $c, $obj, $depth_wanted ) = @_;

    return unless $obj;

    my %data = (
        category          => $obj->get_category(),
        value             => $obj->get_value(),
    );

    return \%data unless $depth_wanted;

    # TermSource handled by superclass; anything else to add here?
    return \%data;
}

sub _summary_method : Private {

    my ( $self, $class ) = @_;

    # Strip the first part of the classname
    $class =~ s/\A Bio::MAGETAB:: //xms;

    # underscore separates internal capitals
    $class =~ s/([a-z])([A-Z])/$1\_$2/g;

    # substitute spaces
    $class =~ s/\s+/\_/g;

    # and then lowercase
    $class = lc($class);

    return "_summarize_$class";
}

sub _pluralize_class : Private {

    my ( $self, $class ) = @_;

    my %irregular_plural = (
        'BaseClass'     => 'BaseClasses',
        'Data'          => 'Data',
        'DataMatrix'    => 'DataMatrices',
        'DatabaseEntry' => 'DatabaseEntries',
    );

    $class =~ s/^.*:://;
    $class = $irregular_plural{$class} || "${class}s";
    $class = lcfirst($class);
    $class =~ s/^SDRF/sdrf/i;

    return $class;
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
