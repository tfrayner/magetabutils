# $Id$

package Bio::MAGETAB::Node;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'inputEdges'          => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Edge]',
                               auto_deref => 1,
                               required   => 0 );

has 'outputEdges'         => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Edge]',
                               weak_ref   => 1,
                               auto_deref => 1,
                               required   => 0 );

has 'factorValues'        => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::FactorValue]',
                               auto_deref => 1,
                               required   => 0 );

has 'comment'             => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
