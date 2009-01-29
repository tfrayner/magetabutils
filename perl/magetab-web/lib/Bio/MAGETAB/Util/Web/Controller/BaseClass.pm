package Bio::MAGETAB::Util::Web::Controller::BaseClass;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::BaseClass - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

__PACKAGE__->mk_accessors( qw( my_model_class ) );

=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body(sprintf("Matched Bio::MAGETAB::%s Controller.", $self->my_model_class() ));
}

=head2 list

=cut

sub list : Local { 
    my ($self, $c) = @_;

    my @objects = $c->model()->storage()->select(
        'Bio::MAGETAB::' . $self->my_model_class());
    $c->stash->{objects} = \@objects;
}

=head2 view

=cut

sub view : Local {

    my ($self, $c, $id) = @_;
    my $object = $c->model()->storage()->load( $id );
    unless ( $object ) {
        $c->flash->{error} = 'No such ' . $self->my_model_class() . '!';
        $c->res->redirect( $c->uri_for( $self->my_error_redirect() ) );
        $c->detach();
    }
    $c->stash->{object} = $object;
}

sub my_error_redirect : Private {

    my ( $self, $c ) = @_;

    my $namespace = $self->action_namespace($c);
    return "/$namespace/list";
}


=head2 begin

Flush the model object cache at the start of every request.

=cut

sub begin : Private {
    my ( $self, $c ) = @_;

    # Flush the model.
    $c->model()->recycle();

    $self->NEXT::begin($c);
}

=head1 AUTHOR

Tim Rayner

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
