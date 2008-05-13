# $Id$

package Bio::MAGETAB::SDRF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'nodes'               => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Node]',
                               auto_deref => 1,
                               required   => 1 );

has 'uri'                 => ( is         => 'rw',
                               isa        => 'Str',   # FIXME needs URI data type
                               required   => 1 );

no Moose;

1;
