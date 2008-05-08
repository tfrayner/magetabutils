# $Id$

package Bio::MAGETAB::Material;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Node' };

# FIXME this is an abstract class; block direct instantiation.

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'type'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 1 );

has 'characteristics'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               required   => 0 );

has 'measurements'        => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Measurement]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
