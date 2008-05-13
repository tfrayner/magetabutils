# $Id$

package Bio::MAGETAB::CompositeElement;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::DesignElement' };

has 'name'                => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

has 'databaseEntries'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::DatabaseEntry]',
                               auto_deref => 1,
                               clearer    => 'clear_databaseEntries',
                               predicate  => 'has_databaseEntries',
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               clearer    => 'clear_comments',
                               predicate  => 'has_comments',
                               required   => 0 );

no Moose;

1;
