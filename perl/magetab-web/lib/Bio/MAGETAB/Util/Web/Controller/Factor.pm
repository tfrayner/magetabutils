package Bio::MAGETAB::Util::Web::Controller::Factor;

use strict;
use warnings;
use parent 'Bio::MAGETAB::Util::Web::Controller::BaseClass';

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::Factor - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->my_model_class( 'Factor' );
    $self->my_container_class( 'Investigation' );

    return $self;
}

=head2 view

=cut

sub view : Local {

    my $self = shift;
    my $c    = shift;
    $self->SUPER::view( $c, @_ );
    my $object = $c->stash->{object}
        or die("Error: No object returned from superclass method.");

    my $remote = $c->model()->storage()->remote( "Bio::MAGETAB::FactorValue" );

    my @values = $c->model()
                   ->storage()
                   ->select( $remote, $remote->{factor} == $object );

    $c->stash->{factorValues} = \@values;
}

=head1 AUTHOR

tfr23

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
