package Catalyst::Model::Tangram;

use Class::Tangram::Generator;
use Tangram 2.07;
use strict;
use base qw/Catalyst::Base/;
use Scalar::Util qw(weaken);
use NEXT;

=head1 NAME

Catalyst::Model::Tangram - Catalyst Model class for Tangram databases

=head1 SYNOPSIS

  $ script/MyApp_create.pl model Tangram dsn user password

  # lib/MyApp/M/model.pm
  package MyApp::M::model;

  use base 'Catalyst::Model::Tangram';

  __PACKAGE__->config(
      dsn           => 'dbi:Pg:dbname=myapp',
      password      => '',
      user          => 'postgres',
      schema        => { classes => [ ... ], },
      options       => { # Tangram::Storage->connect arguments
                         # such as passing a pre-connected
                         # handle
                         # dbh => $dbh
                       },
      # by default, Tangram will attempt to connect to the
      # database, and auto-deploy.  Set these to 0 to disable
      # this behaviour
      # auto_connect  => 0,
      # auto_deploy   => 0,
  );

  1;

  # need examples of usage here...

=head1 DESCRIPTION

This is the model class for using Tangram with Catalyst applications.

To set up, make a class that configures the "schema" property to an
"uncooked" Tangram Schema; in other words, the data structure that is
used as input to L<Tangram::Schema> (and/or
L<Class::Tangram::Generator>, if you are generating your Perl classes
from the same structure with L<Class::Tangram>).

=cut

our $VERSION = '0.01';

__PACKAGE__->mk_accessors('storage');
__PACKAGE__->mk_accessors('gen');

sub new
{
    my ( $self, $c ) = @_;
    $self = $self->NEXT::new($c);
    my %config = (
        options => {},
		  auto_connect => 1,
		  auto_deploy => 1,

        # this can have options here!

        %{ $self->config() },
                 );
    $self->{schema}  = $config{schema};
    $self->{gen}     = Class::Tangram::Generator->new( $self->{schema} );
    $self->{c} = $c;

    if ( $config{auto_connect} ) {

	my $dbh = ($config{options}{dbh}
		   || DBI->connect(@config{qw(dsn user password)},
				   { AutoCommit => 1 }))
	    or die $DBI::errstr;

	$self->{schema_t} = Tangram::Schema->new( $self->{schema} );

	eval {
	    $self->open( dbh => $dbh )
	};
	if ($@) {
	    $dbh->disconnect();
	    if ( $config{auto_deploy} ) {
		$self->{c}->log->warn("connect failed ($@); attempting "
				      ."auto-deploy");
		eval {
		    $self->deploy;
		    $self->open;
		};
		if ( $@ ) {
		    $self->{c}->log->fatal("deploy+connect failed ($@); "
					   ."giving up");
		    die "Error connecting to Tangram storage - $@";
		}
	    }
	}
    }

    return $self;
}

=head1 SCHEMA MANAGEMENT

As Tangram manages its own schema structure, the structure in the code
is the master, not that in the database.

When the application starts up, it will attempt to connect to the
database.  If this fails, it will try to deploy the current schema,
and then try the connection again.

This is generally safe, as most databases will not let you re-create
tables that already exist.  However, it has some caveats;

=over

=item *

B<Tangram 2.08_05 and earlier> might not notice that an empty database
has not been deployed to yet when it is connected to - if you are
using the C<oid_sequence> functionality, then there is no C<tangram>
table from which L<Tangram::Storage> must select from at startup.

=item *

B<Schema Migration> - if you change the Tangram schema, then you also
need to change the database schema.  The simplest way to do this is
just to drop the database and recreate it, or to deploy to a blank
database, then use a utility like C<mysqldiff> or C<oradiff> to
compare the database schemas and advise on what ALTER TABLE, etc
commands need to be issued.

Note that B<this condition cannot easily be detected> at current.

=back

If you wish to deploy or retreat the schema yourself, then call the
C<-E<gt>deploy()> and C<-E<gt>retreat()> methods of your model class.

=head1 MODEL METHODS

The following methods are available to your model class.

=over

=item $model-E<gt>open();

Opens a new connection to Storage (throwing away any old one).  This
will normally have happened automatically on startup.

=item $model-E<gt>is_open();

Returns a true value if the Storage is connected.

=cut

sub open {
    my $self = shift;
    my $config = $self->config;
    $self->{c}->log->debug("connecting to database for ".ref($self)
		      ." ($config->{dsn})");
    $self->{storage} = Tangram::Storage->connect
	( $self->{schema_t},
	  @{$config}{qw(dsn user password)},
	  { %{ $self->config->{options} || {} },
	    @_
	  },
	);
}

sub is_open {
    my $self = shift;
    return $self->{storage} ? $self->{storage}->ping : ();
}

=item $model-E<gt>deploy();

Issues C<CREATE TABLE> statements, etc to set up on the configured
location.

=item $model-E<gt>deploy();

Issues C<DROP TABLE> statements, etc to get rid of a Tangram store
that was set up on the configured location.

=cut

# roll out the model - Tangram 2.11+ recommended for automatic DB type
# detection
sub deploy
{
    my $self = shift;
    my $config = $self->config;
    $self->{c}->log->info("deploying schema for ".ref($self)." to "
		     .$config->{dsn});
    Tangram::Relational->deploy
	    ($self->{schema_t}, @{$config}{qw(dsn user password)});
}

sub retreat
{
    my $self = shift;
    my $config = $self->config;
    $self->{c}->log->info("retreating (dropping) schema for ".ref($self)
		     ." from ".$config->{dsn});
    Tangram::Relational->retreat
	    ($self->{schema_t}, @{$config}{qw(dsn user password)});
}

=item $model-E<gt>recycle([$method])

Calls L<Tangram::Storage/recycle>, which forgets all cached objects,
optionally first sending them the C<$method> signal (which defaults to
C<clear_refs>), rolls back all transactions, and clears all internal
state.

This is important that you do this on the completion of each database
transaction, so that your database can satisfy ACID guarantees.

Please do not even think for a moment, let alone report, that you are
experiencing Tangram storage bugs unless you are calling this method
between each request (or, you are single filing transactions through
an exclusive writer).

=cut

sub recycle
{
    my $self = shift;
    $self->{storage}->recycle if $self->is_open;
}

=back

=cut

# TODO
# # schema helper - tangram schema editor application ?
# # error checking
# # debug
# # dbi options, etc
# # document
# # add tangram debug option per-class

1;

=head1 AUTHOR

Andres Kievsky, C<ank@cpan.org>.

=cut

