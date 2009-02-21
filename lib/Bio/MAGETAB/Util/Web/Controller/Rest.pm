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
        my $class = blessed $object;
        my $method = $self->_summary_method( $class );
        if ( UNIVERSAL::can( $self, $method ) ) {
            $self->status_ok(
                $c,
                entity => $self->$method( $c, $object ),
            );
        }
        else {
            $self->status_bad_request(
                $c,
                message => "Unable to summarize $class objects",
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

    my @data;
    foreach my $obj ( @objects ) {
        push @data, $self->_summarize_investigation( $c, $obj );
    }

    $self->status_ok(
        $c,
        entity => \@data,
    );
}

#
# Methods used to sanitize objects before serialisation.
#

sub _summarize_investigation : Private {

    my ( $self, $c, $obj ) = @_;

    my %data = (
        oid               => $c->model()->storage()->id( $obj ),
        title             => $obj->get_title(),
        description       => $obj->get_description(),
        date              => $obj->get_date(),
        publicReleaseDate => $obj->get_publicReleaseDate(),
    );

    my @factors;
    foreach my $factor ( $obj->get_factors() ) {
        push @factors, $self->_summarize_factor( $c, $factor );
    }
    $data{factors} = \@factors;

    return \%data;
}

sub _summarize_factor : Private {

    my ( $self, $c, $obj ) = @_;

    my %data = (
        oid               => $c->model()->storage()->id( $obj ),
        name              => $obj->get_name(),
        factorType        => $self->_summarize_controlled_term(
                                         $c, $obj->get_factorType() ),
    );

    return \%data;
}

sub _summarize_controlled_term : Private {

    my ( $self, $c, $obj ) = @_;

    my %data = (
        oid               => $c->model()->storage()->id( $obj ),
        category          => $obj->get_category(),
        value             => $obj->get_value(),
    );

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

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
