# $Id$

package Bio::MAGETAB::Contact;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'lastName'            => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'firstName'           => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'midInitials'         => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'email'               => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'organization'        => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'phone'               => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'fax'                 => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'address'             => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'roles'               => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
