package Bio::MAGETAB::Util::Web::View::HTML;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        Bio::MAGETAB::Util::Web->path_to( 'root', 'src' ),
        Bio::MAGETAB::Util::Web->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    TEMPLATE_EXTENSION => '.tt2',
});

=head1 NAME

Bio::MAGETAB::Util::Web::View::HTML - Catalyst TTSite View

=head1 SYNOPSIS

See L<Bio::MAGETAB::Util::Web>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Tim Rayner

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

