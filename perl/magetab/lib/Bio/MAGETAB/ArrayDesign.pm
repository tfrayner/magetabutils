# $Id$

package Bio::MAGETAB::ArrayDesign;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'accession'           => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_accession',
                               predicate  => 'has_accession',
                               required   => 0 );

has 'version'             => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_version',
                               predicate  => 'has_version',
                               required   => 0 );

has 'uri'                 => ( is         => 'rw',
                               isa        => 'Str',   # FIXME needs URI type
                               clearer    => 'clear_uri',
                               predicate  => 'has_uri',
                               required   => 0 );

has 'provider'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_provider',
                               predicate  => 'has_provider',
                               required   => 0 );

has 'technologyType'      => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_technologyType',
                               predicate  => 'has_technologyType',
                               required   => 0 );

has 'surfaceType'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_surfaceType',
                               predicate  => 'has_surfaceType',
                               required   => 0 );

has 'substrateType'       => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_substrateType',
                               predicate  => 'has_substrateType',
                               required   => 0 );

has 'printingProtocol'    => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_printingProtocol',
                               predicate  => 'has_printingProtocol',
                               required   => 0 );

has 'sequencePolymerType' => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_sequencePolymerType',
                               predicate  => 'has_sequencePolymerType',
                               required   => 0 );

has 'designElements'      => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::DesignElement]',
                               auto_deref => 1,
                               clearer    => 'clear_designElements',
                               predicate  => 'has_designElements',
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               clearer    => 'clear_comments',
                               predicate  => 'has_comments',
                               required   => 0 );

no Moose;

1;
