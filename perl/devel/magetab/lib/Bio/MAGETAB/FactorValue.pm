# $Id$

package Bio::MAGETAB::FactorValue;

use Moose;

use List::Util qw(first);

extends 'Bio::MAGETAB::BaseClass';

has 'measurement'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Measurement',
                               required   => 0 );

has 'term'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

has 'channel'             => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

# FIXME this trigger won't work correctly to remove fvs from
# previous factors on update.
has 'factor'              => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Factor',
                               weak_ref   => 1,
                               required   => 1,
                               trigger    => sub { my ( $self, $factor ) = @_;
                                                   my @old = $factor->factorValues();
                                                   unless ( first { $_ eq $self } @old ) {
                                                       push @old, $self;
                                                       $factor->factorValues( \@old );
                                                   }
                                               } );

# FIXME this trigger won't work correctly to remove fvs from
# previous nodes on update.
has 'nodes'               => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Node]',
                               auto_deref => 1,
                               required   => 1,
                               trigger    => sub { my ( $self, $node ) = @_;
                                                   my @old = $node->factorValues();
                                                   unless ( first { $_ eq $self } @old ) {
                                                       push @old, $self;
                                                       $node->factorValues( \@old );
                                                   }
                                               } );

no Moose;

1;
