package Bio::MAGETAB::Util::Web::Controller::Investigation;

use strict;
use warnings;
use parent 'Bio::MAGETAB::Util::Web::Controller::BaseClass';

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::Investigation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->my_model_class( 'Investigation' );

    return $self;
}

=head1 AUTHOR

Tim Rayner

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
