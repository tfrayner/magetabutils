# $Id$

package Bio::MAGETAB::ProtocolParameter;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'protocol'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Protocol',
                               required   => 1 );

no Moose;

1;
