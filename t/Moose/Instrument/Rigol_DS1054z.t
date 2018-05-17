#!perl

# Do not connect anything to the input ports when running this!!!

use warnings;
use strict;
use 5.010;

use lib 't';

use Lab::Test import =>
    [qw/is_float is_absolute_error is_relative_error set_get_test/];
use Test::More;
use Moose::Instrument::MockTest qw/mock_instrument/;
use MooseX::Params::Validate;
use Moose::Instrument::ScopeTest qw/test_scope/;

use File::Spec::Functions 'catfile';
use Module::Load 'autoload';

eval {
    autoload 'PDL::Graphics::Gnuplot';
    1;
} or do {
    plan skip_all => "test requires PDL::Graphics::Gnuplot";
};

my $log_file = catfile(qw/t Moose Instrument Rigol_DS1054z.yml/);

my $inst = mock_instrument(
    type     => 'Rigol_DS1054z',
    log_file => $log_file,
);

isa_ok( $inst, 'Lab::Moose::Instrument::Rigol_DS1054z' );

# generic tests for any Scope.
test_scope( Scope => $inst );

done_testing();

