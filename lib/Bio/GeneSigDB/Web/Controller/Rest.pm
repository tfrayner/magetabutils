#!/usr/bin/env perl
#
# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::GeneSigDB::Web.
# 
# Bio::GeneSigDB::Web is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::GeneSigDB::Web is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::GeneSigDB::Web.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package Bio::GeneSigDB::Web::Controller::Rest;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';

use Scalar::Util qw( blessed );
use Carp;

=head1 NAME

Bio::GeneSigDB::Web::Controller::Rest - Catalyst Controller

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

            # The $depth_wanted argument in this call can be increased
            # to dump more information to the REST user. In practice
            # I'd suggest not going above 3, because otherwise the
            # cycles in the model (Edge-Node, SDRFRow-Node) start to
            # rear their ugly head.
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
            push @data, $self->_summarize_object( $c, $obj );
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

sub _generic_object_hash : Private {

    # Passed an object and a class from which said object is derived,
    # create a hash representing the object values for attributes
    # defined by that class. The $depth_wanted values indicates how
    # much detail should be included and is a means to avoid race
    # conditions. The catalyst context object is included to provide
    # access to the underlying model class.

    my ( $self, $c, $obj, $depth_wanted, $class ) = @_;

    my %data;

    my @attributes = $class->meta()->get_attribute_list();

    foreach my $attr ( @attributes ) {
        my $attr_obj = $class->meta()->get_attribute( $attr );
        my $type     = $attr_obj->type_constraint()->name();
        my $getter   = "get_$attr";

        if ( $type !~ /\A ArrayRef \b/xms && $type !~ /Bio::MAGETAB/ ) {

            # Only the basics are always included (Str, Int, URI,
            # Email or DateTime).
            $data{ $attr } = $obj->$getter;
        }
        elsif ( $depth_wanted ) {

            # If we're doing a detailed serialisation, we look at
            # ArrayRef attributes and attributes linking to other
            # Bio::MAGETAB classes.
            if ( $type =~ /\A ArrayRef \b/xms ) {
                if ( $type =~ /Bio::MAGETAB/ ) {

                    # Array of Bio::MAGETAB objects.
                    $data{ $attr }
                        = [
                            map {
                                $self->_summarize_object(
                                    $c,
                                    $_,
                                    $depth_wanted,
                                )
                            }
                                $obj->$getter ];
                }
                else {

                    # Array of something else (Str, Int, URI, Email or
                    # DateTime).
                    $data{ $attr } = [ $obj->$getter ];
                }
            }
            else {

                # Single Bio::MAGETAB objects.
                $data{ $attr } = $self->_summarize_object(
                    $c,
                    $obj->$getter,
                    $depth_wanted,
                );
            }
        }
    }

    return \%data;
}

sub _summarize_object : Private {

    my ( $self, $c, $obj, $depth_wanted, $class ) = @_;

    my $namespace = 'Bio::MAGETAB';

    $class ||= blessed $obj;

    return unless $class;

    # Return a full serialization. Summarize superclass
    # attributes recursively here. 
    my $data = {};
    CLASS:
    foreach my $super ( $class->meta()->superclasses() ) {

        # Don't follow superclasses outside the Bio::MAGETAB
        # namespace.
        next CLASS unless UNIVERSAL::isa($super, "${namespace}::BaseClass");

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
    my $newdata = $self->_generic_object_hash( $c, $obj, $depth_wanted, $class );
    @{ $data }{keys %$newdata} = values %$newdata;

    # Set some standard attributes.
    $data->{oid} = $c->model()->storage()->id( $obj );
    $class =~ s/^${namespace}:://;
    $data->{class} = $class;

    # And we're done.
    return $data;
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
