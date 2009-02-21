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

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::Rest - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller supporting RESTful database access.

=head1 METHODS

=cut

sub investigation : Local : ActionClass('REST') {}

sub investigation_GET {

    my ( $self, $c, $query ) = @_;

    my $remote  = $c->model()->storage()
                    ->remote( "Bio::MAGETAB::Investigation" );

    # FIXME we will undoubtedly want to expand this query further.
    my @objects = $c->model()->storage()
                    ->select( $remote, $remote->{title}->like("%${query}%")
                                     | $remote->{description}->like("%${query}%") );

    my @data;
    foreach my $obj ( @objects ) {
        push @data, {
            title             => $obj->get_title(),
            description       => $obj->get_description(),
            date              => $obj->get_date(),
            publicReleaseDate => $obj->get_publicReleaseDate(),
        };
    }

    $self->status_ok(
        $c,
        entity => \@data,
    );
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
