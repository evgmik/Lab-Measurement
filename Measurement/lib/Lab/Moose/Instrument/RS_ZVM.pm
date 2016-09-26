package Lab::Moose::Instrument::RS_ZVM;

use 5.010;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Params::Validate;
use Lab::Moose::Instrument qw/getter_params timeout_param validated_getter/;
use Lab::Moose::BlockData;
use Carp;
use Config;
use namespace::autoclean;

our $VERSION = '3.520';

extends 'Lab::Moose::Instrument';

with 'Lab::Moose::Instrument::SCPI::Format' => {
    -excludes => [qw/format_border format_border_query/],
    },
    qw(
    Lab::Moose::Instrument::Common

    Lab::Moose::Instrument::SCPI::Initiate

    Lab::Moose::Instrument::SCPI::Instrument

    Lab::Moose::Instrument::SCPI::Sense::Frequency
    Lab::Moose::Instrument::SCPI::Sense::Function
    Lab::Moose::Instrument::SCPI::Sense::Sweep

    Lab::Moose::Instrument::SCPI::Trace::Data::Response

    Lab::Moose::Instrument::VNASweep
);

sub BUILD {
    my $self = shift;

    #$self->clear();
    #$self->cls(timeout => 5);
}

sub cached_format_data_builder {
    my $self = shift;
    return $self->format_data_query( timeout => 3 );
}

sub sparam_catalog {
    my $self     = shift;
    my $function = $self->cached_sense_function();

    if ( $function !~ /(?<sparam>S[12]{2})/ ) {
        croak "no S-parameter selected";
    }

    my $sparam = $+{sparam};

    return [ "Re($sparam)", "Im($sparam)" ];
}

sub sparam_sweep_data {
    my ( $self, %args ) = validated_getter( \@_ );

    my $channel = $self->cached_instrument_nselect();
    return $self->trace_data_response_all(
        trace => "CH${channel}DATA",
        %args
    );
}

=head1 NAME

Lab::Moose::Instrument::RS_ZVM - Rohde & Schwarz ZVM Vector Network Analyzer

=head1 SYNOPSIS

 my $data = $zvm->sparam_sweep(timeout => 10);
 my $matrix = $data->matrix;

=cut

=head1 METHODS

This driver utilizes the following roles:

=over

=item L<Lab::Moose::Instrument::VNASweep>

This role implements the high-level C<sparam_sweep> method.

=item L<Lab::Moose::Instrument::Common>

=item L<Lab::Moose::Instrument::SCPI::Initiate>

=item L<Lab::Moose::Instrument::SCPI::Instrument>

=item L<Lab::Moose::Instrument::SCPI::Sense::Frequency>

=item L<Lab::Moose::Instrument::SCPI::Sense::Function>

=item L<Lab::Moose::Instrument::SCPI::Sense::Sweep>

=item L<Lab::Moose::Instrument::SCPI::Trace::Data::Response>

=back

=cut

__PACKAGE__->meta->make_immutable();

1;