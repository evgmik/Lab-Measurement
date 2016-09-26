package Lab::Moose::Instrument::SCPI::Calculate::Data;

use Moose::Role;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use Lab::Moose::Instrument::Cache;

use Lab::Moose::Instrument qw/
    channel_param
    getter_params
    validated_channel_getter
    validated_channel_setter
    /;

use namespace::autoclean;

our $VERSION = '3.520';

cache calculate_data_call_catalog => (
    getter => 'calculate_data_call_catalog',
    isa    => 'ArrayRef'
);

sub calculate_data_call_catalog {
    my ( $self, $channel, %args ) = validated_channel_getter( \@_ );

    my $string
        = $self->query( command => "CALC${channel}:DATA:CALL:CAT?", %args );
    $string =~ s/'//g;

    return $self->cached_calculate_data_call_catalog(
        [ split ',', $string ] );
}

sub calculate_data_call {
    my ( $self, %args ) = validated_channel_getter(
        \@_,
        format => { isa => enum( [qw/FDATA SDATA MDATA/] ) }
    );

    my $format  = delete $args{format};
    my $channel = delete $args{channel};

    return $self->query(
        command => "CALC${channel}:DATA:CALL? $format",
        %args
    );

}

1;