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

package Bio::GeneSigDB::Web::Model::DB;

use strict;
use base qw(Catalyst::Model::Tangram);

use Bio::MAGETAB;
# FIXME load all the GeneSigDB classes here as well.
use Bio::GeneSigDB::Persistence;

__PACKAGE__->config(
    dsn           => 'dbi:mysql:test',
    user          => '',
    password      => '',
    schema        => Bio::GeneSigDB::Persistence->class_config(),
);

=head1 NAME

Bio::GeneSigDB::Web::Model::DB - Tangram Model Component

=head1 SYNOPSIS

 FIXME

=head1 DESCRIPTION

FIXME

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
