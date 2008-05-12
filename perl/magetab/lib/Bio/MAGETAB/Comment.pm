# $Id$

package Bio::MAGETAB::Comment;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'value'               => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

no Moose;

1;
