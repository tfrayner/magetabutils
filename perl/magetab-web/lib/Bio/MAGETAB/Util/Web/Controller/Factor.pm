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

package Bio::MAGETAB::Util::Web::Controller::Factor;

use strict;
use warnings;
use parent 'Bio::MAGETAB::Util::Web::Controller::BaseClass';

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::Factor - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->my_model_class( 'Factor' );
    $self->my_container_class( 'Investigation' );

    return $self;
}

=head2 view

=cut

sub view : Local {

    my $self = shift;
    my $c    = shift;
    $self->SUPER::view( $c, @_ );
    my $object = $c->stash->{object}
        or die("Error: No object returned from superclass method.");

    my $remote = $c->model()->storage()->remote( "Bio::MAGETAB::FactorValue" );

    my @values = $c->model()
                   ->storage()
                   ->select( $remote, $remote->{factor} == $object );

    $c->stash->{factorValues} = \@values;
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;