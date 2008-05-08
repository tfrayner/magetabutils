# $Id$

package Bio::MAGETAB::ArrayDesign;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'name'                => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

has 'accession'           => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'version'             => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'uri'                 => ( is       => 'rw',
                               isa      => 'Str',   # FIXME needs URI type
                               required => 0 );

has 'provider'            => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'technologyType'      => ( is       => 'rw',
                               isa      => 'Bio::MAGETAB::ControlledTerm',
                               required => 0 );

has 'surfaceType'         => ( is       => 'rw',
                               isa      => 'Bio::MAGETAB::ControlledTerm',
                               required => 0 );

has 'substrateType'       => ( is       => 'rw',
                               isa      => 'Bio::MAGETAB::ControlledTerm',
                               required => 0 );

has 'printingProtocol'    => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'sequencePolymerType' => ( is       => 'rw',
                               isa      => 'Bio::MAGETAB::ControlledTerm',
                               required => 0 );

has 'designElements'      => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::DesignElement]',
                               auto_deref => 1,
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
