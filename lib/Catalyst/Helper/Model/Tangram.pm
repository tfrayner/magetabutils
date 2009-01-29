package Catalyst::Helper::Model::Tangram;

use strict;
use File::Spec;

=head1 NAME

Catalyst::Helper::Model::Tangram - Helper for Tangram Models

=head1 SYNOPSIS

    script/create.pl model ModelName Tangram dsn user password

=head1 DESCRIPTION

This is the Helper for making Tangram Models.

The Catalyst Model concept is very close to a L<Tangram::Schema>,
which represents your application I<data model>.  The principle
difference is that the application model also encapsulates operations
that happen on your data model, and contains a reference to a
L<Tangram::Storage> handle.

You will still need to deploy your schema (that is - set up the tables
in the database); see L<Catalyst::Model::Tangram> for information
about how this is done.

=head2 METHODS

=over 4

=item mk_compclass

Makes a Tangram Model class for you.

=item mk_comptest

Makes tests.

=back

=cut

sub mk_compclass {
    my ( $self, $helper, $dsn, $user, $pass ) = @_;
    $helper->{dsn}  = $dsn  || '';
    $helper->{user} = $user || '';
    $helper->{pass} = $pass || '';
    my $file = $helper->{file};
    $helper->render_file( 'tangramclass', $file );
}

sub mk_comptest {
    my ( $self, $helper ) = @_;
    my $test = $helper->{test};
    $helper->render_file( 'tangramtest', $test );
}

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Request>,
L<Catalyst::Response>, L<Catalyst::Helper>

=head1 AUTHOR

Andres Kievsky and Sam Vilain

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
__DATA__

__tangramclass__
package [% class %];

use strict;
use base qw(Catalyst::Model::Tangram);

__PACKAGE__->config(
    dsn           => '[% dsn %]',
    user          => '[% user %]',
    password      => '[% pass %]',
   (schema        =>
    {
      (classes =>
       [ # see the Tangram::Schema man page for a description and
         # more examples

	# YourClass => {
	#    fields => {
	#       string => {
	#          property => { sql => "varchar(200)" }
        #       },
	#       iset => {
	#          mythings => { class => "YourThing" },
	#       },
	#    }
	# },

       ],

       # make_object => sub { (shift)->new() },

       # normalize => sub {
       #     my $entity = shift;
       #     $entity =~ s{::}{_}g;
       #     $entity;
       # }

       # sql => sub {
       #     # use sequences rather than a table for ID generation
       #     oid_sequence => "some_sequence"
       # }

      ),
    })
);

=head1 NAME

[% class %] - Tangram Model Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
__tangramtest__
use Test::More tests => 2;
use_ok( Catalyst::Test, '[% app %]' );
use_ok('[% class %]');
