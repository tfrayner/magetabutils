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
use Scalar::Util qw(weaken);

# FIXME we need tests for these two.
has 'authority'           => ( is         => 'rw',
                               isa        => 'Str',
                               default    => q{},
                               required   => 1 );

has 'namespace'           => ( is         => 'rw',
                               isa        => 'Str',
                               default    => q{},
                               required   => 1 );

# This is an abstract class; block direct instantiation.
sub BUILD {

    my ( $self, $params ) = @_;

    foreach my $param ( keys %{ $params } ) {
        my $getter = "get_$param";
        unless ( UNIVERSAL::can( $self, $getter ) ) {
            confess("ERROR: Unrecognised parameter: $param");
        }
    }

    if ( blessed $self eq __PACKAGE__ ) {
        confess("ERROR: Attempt to instantiate abstract class " . __PACKAGE__);
    }

    if ( my $container = __PACKAGE__->get_ClassContainer() ) {
        weaken $self;
        $container->add_objects( $self );
    }

    return;
}

{   # This is a class variable pointing to the container object with
    # which, when set, instantiated BaseClass objects will register.

    my $container;

    sub set_ClassContainer {

        my ( $self, $cont ) = @_;
        
        $container = $cont;
    }

    sub get_ClassContainer {

        my ( $self ) = @_;

        return $container;
    }
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
