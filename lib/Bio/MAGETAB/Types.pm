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

1;
