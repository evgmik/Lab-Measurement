package Moose::Instrument::ScopeTest;

use 5.010;
use warnings;
use strict;

use Exporter 'import';

use lib 't';

use Module::Load;
use Lab::Test import => [
    qw/is_float is_absolute_error is_relative_error set_get_test scpi_set_get_test/
];
use Test::More;
use MooseX::Params::Validate;

our @EXPORT_OK = qw/test_scope/;

sub test_scope {
    my %args = validated_hash(
        \@_,
        Scope => { isa => 'Lab::Moose::Instrument' },
    );

    my $s = delete $args{Scope};

    is( $s->get_UnitX, "S",        "the UnitX is 'Seconds'" );
    is( $s->get_NameX, "Time", "the NameX is 'Time'" );
    is( $s->get_UnitY, "V",        "the UnitY is 'V'" );
    is( $s->get_NameY, "Voltage", "the NameY is 'Voltage'" );

    # trace subsystem

    my $traceX
        = $s->get_traceX( trace => 1 ); 
    my $Xpoints_number = $traceX->nelem();

    my $traceXY
        = $s->get_traceXY( trace => 1 );    # we must have at least trace one

    is_deeply(
        [ $traceXY->dims() ], [ $Xpoints_number, 2 ],
        "trace has proper dimensions"
    );

    my $traces12_data
        = $s->get_traces_data( timeout => 1, traces=>[1, 2] );    # all reasonable scopes have 2 channel

    is_deeply(
        [ $traces12_data->dims() ], [ $Xpoints_number, 3 ],
        "traces have proper dimensions"
    );

}

1;
