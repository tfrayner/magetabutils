# $Id$

package Bio::MAGETAB::Publication;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'title'               => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_title',
                               predicate  => 'has_title',
                               required   => 0 );

has 'authorList'          => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_authorList',
                               predicate  => 'has_authorList',
                               required   => 0 );

has 'pubMedID'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_pubMedID',
                               predicate  => 'has_pubMedID',
                               required   => 0 );

has 'DOI'                 => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_DOI',
                               predicate  => 'has_DOI',
                               required   => 0 );

has 'status'              => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_status',
                               predicate  => 'has_status',
                               required   => 0 );

no Moose;

1;
