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

package Bio::MAGETAB::Util::Web::Controller::BaseClass;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::BaseClass - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

__PACKAGE__->mk_accessors( qw( my_model_class my_container_class ) );

=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body(sprintf("Matched Bio::MAGETAB::%s Controller.", $self->my_model_class() ));
}

=head2 list

=cut

sub list : Local { 
    my ($self, $c) = @_;

    my @objects = $c->model()->storage()->select(
        'Bio::MAGETAB::' . $self->my_model_class());
    $c->stash->{objects} = \@objects;
}

=head2 view

=cut

sub view : Local {

    my ($self, $c, $id) = @_;
    my $object = $c->model()->storage()->load( $id );
    unless ( $object ) {
        $c->flash->{error} = 'No such ' . $self->my_model_class() . '!';
        $c->res->redirect( $c->uri_for( $self->my_error_redirect() ) );
        $c->detach();
    }
    $c->stash->{object} = $object;

    $c->stash->{containers} = $self->select_container_objects($c, $object);
}

sub select_container_objects : Private {

    my ( $self, $c, $object ) = @_;

    my @containers;

    if ( my $cont = $self->my_container_class() ) {
        my $remote = $c->model()->storage()->remote( "Bio::MAGETAB::$cont" );

        # FIXME pluralisation rules may need to be applied for some
        # irregular plurals.
        my $class = $self->my_model_class();
        my $key;
        if ( $class eq 'SDRF' ) {
            $key = 'sdrfs';
        }
        else{
            $key = lcfirst( $self->my_model_class() ) . 's';
        }
        @containers = $c->model()
                        ->storage()
                        ->select( $remote, $remote->{$key}->includes( $object ) );
    }

    return \@containers if scalar @containers;
}

sub my_error_redirect : Private {

    my ( $self, $c ) = @_;

    my $namespace = $self->action_namespace($c);
    return "/$namespace/list";
}


=head2 begin

Flush the model object cache at the start of every request.

=cut

sub begin : Private {
    my ( $self, $c ) = @_;

    # Flush the model.
    $c->model()->recycle();

    $self->NEXT::begin($c);
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
