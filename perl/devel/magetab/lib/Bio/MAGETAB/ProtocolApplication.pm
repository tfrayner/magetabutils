# $Id$

package Bio::MAGETAB::ProtocolApplication;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'protocol'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Protocol',
                               required   => 1 );

has 'parameterValues'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGE::ParameterValue]',
                               auto_deref => 1,
                               required   => 0 );

has 'performers'          => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGE::Contact]',
                               auto_deref => 1,
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGE::Comment]',
                               auto_deref => 1,
                               required   => 0 );

has 'date'                => ( is         => 'rw',
                               isa        => 'Str',    # FIXME needs DateTime data type.
                               required   => 0 );

no Moose;

1;
