# Copyright 2008 Tim Rayner
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

package Bio::MAGETAB::Extract;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Material' };

__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::MAGETAB::Extract - MAGE-TAB extract class

=head1 SYNOPSIS

 use Bio::MAGETAB::Extract;

=head1 DESCRIPTION

This class is used to store information on biological extracts (e.g.,
RNA, DNA) in MAGE-TAB. See the L<Material|Bio::MAGETAB::Material> class for superclass
methods.

=head1 ATTRIBUTES

No class-specific attributes. See L<Bio::MAGETAB::Material>.

=head1 METHODS

No class-specific methods. See L<Bio::MAGETAB::Material>.

=head1 SEE ALSO

L<Bio::MAGETAB::Material>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
