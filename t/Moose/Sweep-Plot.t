#!perl

use warnings;
use strict;
use 5.010;
use lib 't';
use Test::More;
use Lab::Test import => ['file_ok'];
use Test::File;
use Module::Load 'autoload';
use Lab::Moose;
use File::Glob 'bsd_glob';
use File::Spec::Functions 'catfile';

use File::Temp qw/tempdir/;

eval {
    autoload 'PDL::Graphics::Gnuplot';
    1;
} or do {
    plan skip_all => "test requires PDL::Graphics::Gnuplot";
};

my $dir = our_catfile( tempdir(), 'sweep' );

# P::G::G cannot handle backslash filename on windows
$dir =~ s{\\}{/}g;

sub dummysource {
    return instrument(
        type                 => 'DummySource',
        connection_type      => 'Debug',
        connection_options   => { verbose => 0 },
        verbose              => 0,
        max_units            => 10,
        min_units            => -10,
        max_units_per_step   => 100,
        max_units_per_second => 1000000,
    );
}

{
    #
    # 1D sweep with plot
    #

    my $source = dummysource();
    my $sweep  = sweep(
        type       => 'Step::Voltage',
        instrument => $source,
        from       => 0,
        to         => 0.5,
        step       => 0.1
    );

    my $datafile = sweep_datafile( columns => [qw/level value/] );

    $datafile->add_plot( x => 'level', y => 'value', live => 0 );

    my $value = 0;
    my $meas  = sub {
        my $sweep = shift;
        $sweep->log( level => $source->get_level, value => $value++ );
    };
    $sweep->start(
        measurement => $meas,
        datafiles   => [$datafile],
        folder      => $dir,

        # use default datafile_dim and point_dim
    );

    my $foldername     = $sweep->foldername;
    my @files          = bsd_glob( catfile( $foldername, '*' ) );
    my @expected_files = qw/data.dat data.png META.yml Sweep-Plot.t/;
    @expected_files = map { catfile( $foldername, $_ ) } @expected_files;
    is_deeply( \@files, \@expected_files, "output folder" );
}

warn "dir: $dir";

done_testing();
