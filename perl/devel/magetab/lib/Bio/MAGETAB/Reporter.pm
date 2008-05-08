# $Id$

package Bio::MAGETAB::Reporter;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::DesignElement' };

has 'name'                => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

has 'sequence'            => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'databaseEntries'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::DatabaseEntry]',
                               auto_deref => 1,
                               required   => 0 );

has 'controlType'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

has 'groups'              => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               required   => 0 );

has 'features'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Feature]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
