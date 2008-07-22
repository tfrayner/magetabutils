# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB.
# 
# Bio::MAGETAB is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package Bio::MAGETAB::Util::Reader::TagValueFile;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;
use List::Util qw(first);

BEGIN { extends 'Bio::MAGETAB::Util::Reader::Tabfile' };

has 'text_store'          => ( is         => 'rw',
                               isa        => 'HashRef',
                               default    => sub { {} },
                               required   => 1 );

has 'dispatch_table'      => ( is         => 'rw',
                               isa        => 'HashRef',
                               default    => sub { {} },
                               required   => 1 );

my $COMMENT_TAG = qr/\A \s* Comment \s* \[ ([^\]]+) \] \s* \z/ixms;

# Define some standard regexps:
my $RE_EMPTY_STRING             = qr{\A \s* \z}xms;
my $RE_COMMENTED_STRING         = qr{\A [\"\s]* \#}xms;
my $RE_SURROUNDED_BY_WHITESPACE = qr{\A [\"\s]* (.*?) [\"\s]* \z}xms;

###################
# Private methods #
###################

sub _create_termsources {

    my ( $self ) = @_;

    my @termsources;
    foreach my $ts_data ( @{ $self->get_text_store()->{'termsource'} } ) {
        my $termsource = $self->get_builder()->find_or_create_termsource( $ts_data );
	push @termsources, $termsource;
    }

    return \@termsources;
}

sub _create_controlled_terms {

    my ( $self, $type, $category ) = @_;

    my @terms;
    foreach my $term_data ( @{ $self->get_text_store()->{ $type } } ) {

        my $termsource;
        if ( my $ts = $term_data->{'termSource'} ) {
            $termsource = $self->get_builder()->get_term_source( $ts );
        }

        my $args = {
            'category'   => $category,
            'value'      => $term_data->{'value'},
            'accession'  => $term_data->{'accession'},
            'termSource' => $termsource,
        };

        my $term = $self->get_builder()->find_or_create_controlled_term( $args );

	push @terms, $term;
    }

    return \@terms;
}

sub _create_comments {

    my ( $self ) = @_;

    my @comments;
    while ( my ( $name, $value ) = each %{ $self->get_text_store()->{'comment'} } ) {

        my $comment = $self->get_builder()->find_or_create_comment({
            'name'    => $name,
            'value'   => $value,
        });

	push @comments, $comment;
    }

    return \@comments;
}

sub _read_as_arrayref {

    # Method to parse the TagValueFile object file into an array of
    # arrayrefs. This method uses Text::CSV_XS to parse tab-delimited
    # text.

    my ( $self ) = @_;

    # First, determine the file linebreak type and generate a CSV
    # parser object.
    my $csv_parser = $self->_get_csv_parser();

    # This is still required for Text::CSV_XS.
    local $/ = $self->_calculate_eol_char();

    # Open the file
    my $fh = $self->_get_filehandle();

    my (@rows, $larry);

    FILE_LINE:
    while ( $larry = $csv_parser->getline($fh) ) {

        # Skip empty lines.
        my $line = join( q{}, @$larry );
        next FILE_LINE if ( $line =~ $RE_EMPTY_STRING );

        # Allow hash comments.
        next FILE_LINE if ( $line =~ $RE_COMMENTED_STRING );

	# Strip surrounding whitespace from each element.
	foreach my $element ( @$larry ) {
	    $element =~ s/$RE_SURROUNDED_BY_WHITESPACE/$1/xms;
	}

	# Strip off empty trailing values.
	my $end_value;
	until ( defined($end_value) && $end_value !~ /\A \s* \z/xms ) {
	    $end_value = pop(@$larry);
	}
	push @$larry, $end_value;

	# Reset empty strings to undefs.
	foreach my $value ( @$larry ) {
	    undef($value) if ( defined($value) && $value eq q{} );
	}

	push @rows, $larry;
    }

    # Check we've parsed to the end of the file.
    my ( $error, $mess ) = $csv_parser->error_diag();
    unless ( $error == 2012 ) {    # 2012 is the Text::CSV_XS EOF code.
	croak(
	    sprintf(
		"Error in tab-delimited format: %s. Bad input was:\n\n%s\n",
		$mess,
		$csv_parser->error_input(),
	    ),
	);
    }

    return \@rows;
}

sub _normalize_tag {

    # Takes a string, returns the lowercase, whitespace-stripped
    # version.
    my ( $self, $tag ) = @_;

    $tag =~ s/\s+//g;
    $tag = lc($tag);

    return $tag
}

sub _validate_arrayref_tags {

    # Method to check the return value from _read_as_arrayref to check
    # for (a) duplicate tags, and (b) unrecognised tags. Returns a
    # hash with keys corresponding to known tags and value arrayrefs
    # containing the file annotation.

    my ($self, $array_of_rows) = @_;

    # Duplicate tag check. This is somewhat primitive at the moment,
    # and can be fooled FIXME.
    my (%seen);
    foreach my $row ( @$array_of_rows ) {

	# Two-dimensional hash; normalized then actual file tags.
	my $normtag = $self->_normalize_tag( $row->[0] );
	$seen{ $normtag }{ $row->[0] } ++;
    }
    while ( my ($norm_tag, $file_tags) = each %seen ) {

	# Differently typed but identical tags.
	if ( scalar (grep { defined $_ } values %$file_tags ) > 1 ) {
	    my $tagstring = join(", ", keys %$file_tags);
	    $self->raise_error(qq{Error: duplicated tag(s): "$tagstring"});
	}

	# Identically typed duplicate tags.
	while ( my ($file_tag, $count) = each %$file_tags ) {
	    if ( $count > 1 ) {
		$self->raise_error(qq{Error: duplicated tag: "$file_tag"});
	    }
	}
    }

    # Hash of row tag keys with rest-of-row arrayref values.
    my %file_hash = map
	{ $_->[0] => [ @{ $_ }[1 .. $#$_] ] }
	    @{ $array_of_rows };

    # A list of acceptable tags, expressed as qr//
    my @acceptable = keys %{ $self->get_dispatch_table() };
    while ( my ( $tag, $values ) = each %file_hash ) {

	# N.B. acceptable tag REs may contain whitespace; no x option
	# here.
	next if $tag =~ /\A\s*$COMMENT_TAG\s*\z/ms;

	# Check for recognised tags here.
	unless ( first { $tag =~ /\A\s*$_\s*\z/ms } @acceptable ) {
	    $self->raise_error(qq{Error: unrecognized tag(s): "$tag"});
	}

	# Empty Name tags are invalid and will cause fatal crashes
	# later; we check for them here.
	if ( $tag =~ m/name \s* \z/ixms ) {
	    foreach my $value ( @$values ) {
		warn(
		    qq{Warning: Name attribute "$tag" is empty.\n}
		) unless $value;
	    }
	}
    }

    return \%file_hash;
}

sub _add_grouped_data {

    # Create an ordered set of data groups indexed by $i.
    my ( $self, $group, $tag, @args ) = @_;

    for ( my $i = 0; $i <= $#args; $i++ ) {
        $self->get_text_store()->{ $group }[$i]{ $tag } = $args[$i];
    }

    return;
}

sub _add_singleton_data {

    # Record a 1:n object:args relationship.
    my ( $self, $group, $tag, @args ) = @_;

    # Make a copy of @args, just in case.
    $self->get_text_store()->{ $group }{ $tag } = [ @args ];

    return;
}

sub _add_singleton_datum {

    # Record a 1:1 group:arg relationship.
    my ( $self, $group, $tag, $arg ) = @_;

    $self->get_text_store()->{ $group }{ $tag } = $arg;

    return;
}

sub _add_comment {

    # Comments are currently processed at the level of the top-level
    # enclosing object (Investigation or ArrayDesign) only.
    my ( $self, $name, $value ) = @_;

    $self->get_text_store()->{ 'comment' }{ $name } = $value;

    return;
}
    
sub _retrieve_sub {

    my ( $self, $tag ) = @_;

    my $rc;

    while ( my ( $key, $sub ) = each %{ $self->get_dispatch_table() } ) {

	# $key may contain whitespace, no x option here.
	if ( $tag =~ /\A\s*$key\s*\z/ms ) {
	    $rc = $sub;
	}
	
	# Have to loop through the rest of the list to reset while()
	# on the hash.
    }

    return $rc;
}

sub _dispatch {

    my ( $self, $tag, @args ) = @_;

    unless (defined $tag) {
	confess("Error: dispatch needs a defined tag name.");
    }

    my $sub = $self->_retrieve_sub( $tag );
    unless (defined $sub && ref $sub eq 'CODE') {
	if ( my ( $commentname ) = ( $tag =~ /\A\s*$COMMENT_TAG\s*\z/ms ) ) {
	    $self->_add_comment($commentname, @args);
	}
	else {

	    # This should have been caught in _validate_arrayref_tags
	    croak(qq{Error: Cannot parse the tag: "$tag".});
	}
    }

    return $sub ? $sub->(@args) : undef;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
