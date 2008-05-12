# $Id$

package Bio::MAGETAB::Protocol;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'text'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 0 );

has 'software'            => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 0 );

has 'hardware'            => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 0 );

has 'type'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

no Moose;

1;
