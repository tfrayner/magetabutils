# Copyright 2008-2010 Tim Rayner
# 
# This file is part of Bio::MAGETAB.
# 
# Bio::MAGETAB is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package Bio::MAGETAB::Util::DBLoader;

use Moose;

use Carp qw(cluck);

BEGIN { extends 'Bio::MAGETAB::Util::Tangram::Loader'; }

sub BUILD {

    my ( $self, $params ) = @_;

    cluck( "The Bio::MAGETAB::Util::DBLoader class is deprecated and"
         . " will shortly be removed. Please use"
         . " Bio::MAGETAB::Util::Tangram::Loader as a drop-in replacement." );

    return;
}

__PACKAGE__->meta->make_immutable();

no Moose;

=head1 NAME

Bio::MAGETAB::Util::DBLoader - (DEPRECATED) Tangram-based object
persistence class for MAGE-TAB.

=head1 DESCRIPTION

This class has been renamed to Bio::MAGETAB::Util::Tangram::Loader.

=head1 SEE ALSO

L<Bio::MAGETAB::Util::Tangram::Loader>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
