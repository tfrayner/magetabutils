# $Id$

package Bio::MAGETAB::ParameterValue;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'measurement'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Measurement',
                               required   => 1 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGE::Comment]',
                               auto_deref => 1,
                               required   => 0 );

has 'parameter'           => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ProtocolParameter',
                               required   => 1 );

no Moose;

1;
