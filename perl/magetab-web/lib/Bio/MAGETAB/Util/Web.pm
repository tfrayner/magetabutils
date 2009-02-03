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

package Bio::MAGETAB::Util::Web;

use strict;
use warnings;

use 5.008001;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/-Debug
                ConfigLoader
                Static::Simple/;
our $VERSION = '0.02';

# Configure the application. 
#
# Note that settings in bio_magetab_util_web.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( name          => 'Bio::MAGETAB::Util::Web',
                     default_model => 'DB' );

# Start the application
__PACKAGE__->setup();

# We embed the standard Tangram ID method into uri_for to make life easier.
sub uri_for {
    my $self = shift;
    for ( my $i = 0; $i < scalar @_; $i++ ) {
        if ( UNIVERSAL::isa( $_[$i], 'Bio::MAGETAB::BaseClass' ) ) {
            $_[$i] = $self->model->storage->id( $_[$i] )
        }
    }
    return $self->NEXT::uri_for( @_ );
}

=head1 NAME

Bio::MAGETAB::Util::Web - Catalyst based web application for MAGE-TAB Utilities

=head1 SYNOPSIS

    script/bio_magetab_util_web_server.pl

=head1 DESCRIPTION

This is a web application, built using MAGE-TAB Utilities and the
Catalyst framework, which allows the user to interact with MAGE-TAB
metadata stored in a database back-end. The database is managed via
the Bio::MAGETAB::Util::Persistence and Bio::MAGETAB::Util::DBLoader
modules, and is based on the Tangram object persistence mechanism.

=head1 SEE ALSO

L<Bio::MAGETAB::Util::Web::Controller::Root>, Catalyst, L<Bio::MAGETAB>, L<Bio::MAGETAB::Util::Persistence>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
