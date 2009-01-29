package Bio::MAGETAB::Util::Web::Controller::Investigation;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::Investigation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Bio::MAGETAB::Util::Web::Controller::Investigation in Investigation.');
}

=head2 list

=cut

sub list : Local { 
    my ($self, $c) = @_;
    my @investigations = $c->model()->storage()->select('Bio::MAGETAB::Investigation');
    $c->stash->{objects} = \@investigations;
}

=head1 AUTHOR

Tim Rayner

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
