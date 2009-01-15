# $Id$

use strict;
use warnings;

use base qw(Exporter);
our @EXPORT_OK = qw( test_parse check_term );

sub test_parse {

    my ( $reader ) = @_;

    $reader->parse();

    return $reader->get_magetab_object();
}

sub check_term {

    my ( $cat, $val, $attr, $obj, $ts, $builder ) = @_;

    my $method = "get_$attr";

    my $ct;
    lives_ok( sub { $ct = $builder->get_controlled_term({
        category   => $cat,
        value      => $val,
        termSource => $ts,
    }) }, "Builder returns a $cat term" );
    is( $ct->get_termSource(), $ts, 'with the correct termSource' );
    is_deeply( $obj->$method(), $ct, '$attr set correctly' );

    return;
}

1;
