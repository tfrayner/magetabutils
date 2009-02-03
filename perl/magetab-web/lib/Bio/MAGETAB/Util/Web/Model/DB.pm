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

package Bio::MAGETAB::Util::Web::Model::DB;

use strict;
use base qw(Catalyst::Model::Tangram);

use Bio::MAGETAB;
use Bio::MAGETAB::Util::Persistence;

__PACKAGE__->config(
    dsn           => 'dbi:mysql:test',
    user          => '',
    password      => '',
    schema        => Bio::MAGETAB::Util::Persistence->class_config(),
);

=head1 NAME

Bio::MAGETAB::Util::Web::Model::DB - Tangram Model Component

=head1 SYNOPSIS

 FIXME

=head1 DESCRIPTION

FIXME

=head1 AUTHOR

Tim Rayner

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
