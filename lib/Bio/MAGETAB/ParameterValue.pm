# $Id$

package Bio::MAGETAB::ParameterValue;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'measurement'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Measurement',
                               required   => 1 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               clearer    => 'clear_comments',
                               predicate  => 'has_comments',
                               required   => 0 );

has 'parameter'           => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ProtocolParameter',
                               required   => 1 );

no Moose;

1;
