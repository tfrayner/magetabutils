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

package Bio::MAGETAB::Util::Writer::ADF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

BEGIN { extends 'Bio::MAGETAB::Util::Writer::BaseClass' };

has 'magetab_object'     => ( is         => 'ro',
                              isa        => 'Bio::MAGETAB::ArrayDesign',
                              required   => 1 );

sub write {

    my ( $self ) = @_;

    my $fh    = $self->get_filehandle();
    my $array = $self->get_magetab_object();

}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
