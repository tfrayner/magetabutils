# $Id$

package Bio::MAGETAB::ProtocolApplication;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'protocol'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Protocol',
                               required   => 1 );

has 'parameterValues'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ParameterValue]',
                               auto_deref => 1,
                               clearer    => 'clear_parameterValues',
                               predicate  => 'has_parameterValues',
                               required   => 0 );

has 'performers'          => ( is         => 'rw',
                               isa        => 'ArrayRef[Str]',
                               auto_deref => 1,
                               clearer    => 'clear_performers',
                               predicate  => 'has_performers',
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               clearer    => 'clear_comments',
                               predicate  => 'has_comments',
                               required   => 0 );

has 'date'                => ( is         => 'rw',
                               isa        => 'Str',    # FIXME needs DateTime data type.
                               clearer    => 'clear_date',
                               predicate  => 'has_date',
                               required   => 0 );

no Moose;

1;
