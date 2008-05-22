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

package Bio::MAGETAB::BaseClass;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;
use List::Util qw(first);

# This is an abstract class; block direct instantiation.
sub BUILD {

    my ( $self, $params ) = @_;

    foreach my $param ( keys %{ $params } ) {
        my $getter = "get_$param";
        unless ( $self->can( $getter ) ) {
            confess("ERROR: Unrecognised parameter: $param");
        }
    }

    if ( blessed $self eq __PACKAGE__ ) {
        confess("ERROR: Attempt to instantiate abstract class " . __PACKAGE__);
    }

    if ( my $container = __PACKAGE__->get_container() ) {
        $container->add_object( $self );
    }

    return;
}

{   # This is a class variable pointing to the container object with
    # which, when set, instantiated BaseClass objects will register.

    my $container;

    sub set_container {

        my ( $self, $cont ) = @_;
        
        $container = $cont;
    }

    sub get_container {

        my ( $self ) = @_;

        return $container;
    }
}

# This method is used as a wrapper to ensure that reciprocating
# relationships are maintained, even when updating object attributes.
sub _reciprocate_1toN_attribute_setting {

    # $attr :       CODEREF for setting attribute
    #                 (see Moose docs, particularly with regard to "around").
    # $target:      The object with which $self has a reciprocal relationship.
    #                 This can be either a scalar or an arrayref.
    # $self_slot:   The name of the slot pointing from $self to $target.
    # $target_slot: The name of the slot pointing from $target to $self.
    my ( $self, $attr, $target, $self_slot, $target_slot ) = @_;

    my $self_getter   = "get_$self_slot";
    my $target_getter = "get_$target_slot";
    my $target_setter = "set_$target_slot";

    # Remove $self from the list held by the old $target.
    my $old_target = $self->$self_getter();
    if ( $old_target ) {

        # Coerce such that scalar and array attributes can both be
        # processed alike.
        my $targets = ref $old_target eq 'ARRAY'
                    ? $old_target
                    : [ $old_target ];

        foreach my $t ( @{ $targets } ) {
            my @cleaned;
            foreach my $item ( $t->$target_getter() ) {
                push @cleaned, $item unless ( $item eq $self );
            }
            $t->{ $target_slot } = \@cleaned;
        }
    }

    # Set the appropriate $self attribute to point to $target.
    $attr->( $self, $target );

    # Make sure $target points to us.
    my $targets = ref $target eq 'ARRAY'
                ? $target
                : [ $target ];
    foreach my $t ( @$targets ) {
        my @current = $t->$target_getter();
        unless ( first { $_ eq $self } @current ) {
            push @current, $self;
            $t->{ $target_slot } = \@current;
        }
    }

    return;
}

# Make the classes immutable. In theory this speeds up object
# instantiation, this is however untested and may even need to be done
# separately for each subclass.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
