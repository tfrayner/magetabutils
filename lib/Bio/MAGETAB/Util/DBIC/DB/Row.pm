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

package Bio::MAGETAB::Util::DBIC::DB::Row;

use Moose;

BEGIN { extends 'DBIx::Class::Row'; }

sub set_column {

    my $self   = shift;
    my $column = shift;

    my $rc;
    if ( $self->has_column( $column ) ) {
        $rc = $self->next::method($column, @_);
    }
    else {
        my $parent = $self->result_source->resultset->_parent_relationship;
        $rc = $self->$parent->set_column( $column, @_ );
    }

    return $rc;
}

sub get_column {

    my $self   = shift;
    my $column = shift;

    if ( $self->has_column( $column ) ) {
        return $self->next::method( $column, @_ );
    }
    else {
        my $parent = $self->result_source->resultset->_parent_relationship;
        return $self->$parent->get_column( $column );
    }
}

sub update {

    my $self = shift;

    my $parent = $self->result_source->resultset->_parent_relationship;
    $self->$parent->update(@_);

    $self->next::method(@_);
}

sub delete {

    my $self = shift;

    my $parent = $self->result_source->resultset->_parent_relationship;
    $self->$parent->delete();

    $self->next::method(@_);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

no Moose;

1;

__END__

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
