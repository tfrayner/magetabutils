package Bio::MAGETAB::Util::Web::Model::DB;

use strict;
use base qw(Catalyst::Model::Tangram);

use Bio::MAGETAB;
use Bio::MAGETAB::Util::Persistence;

__PACKAGE__->config(
    dsn           => 'dbi:mysql:test',
    user          => '',
    password      => '',
    schema        => Bio::MAGETAB::Util::Persistence->class_config(),
);

=head1 NAME

Bio::MAGETAB::Util::Web::Model::DB - Tangram Model Component

=head1 SYNOPSIS

 FIXME

=head1 DESCRIPTION

FIXME

=head1 AUTHOR

Tim Rayner

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
