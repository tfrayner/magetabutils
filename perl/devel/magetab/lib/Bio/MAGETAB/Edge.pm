# $Id$

package Bio::MAGETAB::Edge;

use Moose;

use List::Util qw(first);

extends 'Bio::MAGETAB::BaseClass';

# FIXME this trigger won't work correctly to remove edges from
# previous nodes on update.
has 'inputNode'           => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Node',
                               required   => 1,
                               trigger    => sub { my ( $self, $node ) = @_;
                                                   my @old = $node->outputEdges();
                                                   unless ( first { $_ eq $self } @old ) {
                                                       push @old, $self;
                                                       $node->outputEdges( \@old );
                                                   }
                                               } );

# FIXME this trigger won't work correctly to remove edges from
# previous nodes on update.
has 'outputNode'          => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Node',
                               weak_ref   => 1,
                               required   => 1,
                               trigger    => sub { my ( $self, $node ) = @_;
                                                   my @old = $node->inputEdges();
                                                   unless ( first { $_ eq $self } @old ) {
                                                       push @old, $self;
                                                       $node->inputEdges( \@old );
                                                   }
                                               } );

has 'protocolApplications' => ( is         => 'rw',
                                isa        => 'ArrayRef[Bio::MAGETAB::ProtocolApplication]',
                                auto_deref => 1,
                                required   => 0 );


no Moose;

1;
