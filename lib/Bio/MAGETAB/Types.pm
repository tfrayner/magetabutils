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

use strict;
use warnings;

package Bio::MAGETAB::Types;

use MooseX::Types
    -declare => [ qw( Uri Date Email ) ];

use URI;
use DateTime;
use Email::Valid;
use Params::Coerce;

subtype 'Uri'

    => as 'Object'
    => where { UNIVERSAL::isa( $_, 'URI' ) };

coerce 'Uri'

    => from 'Object'
    => via { UNIVERSAL::isa( $_, 'URI' )
                 ? $_
                 : Params::Coerce::coerce( 'URI', $_ ) }

    => from 'Str'
    => via {
        my $uri = URI->new( $_ );

        # We assume here that thet default URI scheme is "file".
        unless ( $uri->scheme() ) {
            $uri->scheme('file');
        }
        return $uri;
    };

subtype 'Date'

    => as 'Object'
    => where { UNIVERSAL::isa( $_, 'DateTime' ) };

coerce 'Date'

    => from 'Object'
    => via { UNIVERSAL::isa( $_, 'DateTime' )
                 ? $_
                 : Params::Coerce::coerce( 'DateTime', $_ ) }

    => from 'HashRef'
    => via {
        DateTime->new(%$_);
    }

    => from 'Str'
    => via {
        require DateTime::Format::DateManip;
        DateTime::Format::DateManip->parse_datetime($_);
    };

subtype 'Email'

    => as 'Str'
    => where { Email::Valid->address( $_ ) };

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::MAGETAB::Types - custom data types for Bio::MAGETAB

=head1 SYNOPSIS

 use Bio::MAGETAB::Types qw( Date Email Uri );

=head1 DESCRIPTION

This class provides definitions and coercion methods for Bio::MAGETAB
data types not included as part of Moose. It is not intended to be
used directly, but is instead called by many of the individual
MAGE-TAB classes.

=head1 TYPES

=over 2

=item Date

Dates are stored and retrieved as DateTime objects. Constructors and
mutators can be passed either a DateTime object, a hashref suitable
for passing to DateTime->new(), or a string date representation. In
the latter case this class attempts to parse the string into a
DateTime object using the Date::Manip module.

=item Email

Email addresses are stored as strings, but are validated using the
Email::Valid module.

=item Uri

All URI strings are stored and retrieved as instances of the standard
perl URI class.

=back

=head1 SEE ALSO

DateTime, Date::Manip, Email::Valid, URI

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
