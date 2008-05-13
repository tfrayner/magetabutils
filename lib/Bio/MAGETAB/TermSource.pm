# $Id$

package Bio::MAGETAB::TermSource;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'uri'                 => ( is         => 'rw',
                               isa        => 'Str',    # FIXME needs URI data type.
                               clearer    => 'clear_uri',
                               predicate  => 'has_uri',
                               required   => 0 );

has 'version'             => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_version',
                               predicate  => 'has_version',
                               required   => 0 );

no Moose;

1;
