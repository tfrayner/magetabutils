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
                               clearer    => 'clear_text',
                               predicate  => 'has_text',
                               required   => 0 );

has 'software'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_software',
                               predicate  => 'has_software',
                               required   => 0 );

has 'hardware'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_hardware',
                               predicate  => 'has_hardware',
                               required   => 0 );

has 'type'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_type',
                               predicate  => 'has_type',
                               required   => 0 );

no Moose;

1;
