package Lab::Moose::Instrument::Rigol_DS1054z;

#ABSTRACT: Rigol DS1054z Scope

use 5.010;

use PDL::Core qw/pdl cat nelem/;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Params::Validate;
use Lab::Moose::Instrument qw/
    timeout_param
    precision_param
    validated_getter
    validated_setter
    validated_channel_getter
    validated_channel_setter
    /;
use Lab::Moose::Instrument::Cache;
use Carp;
use POSIX 'strftime';
use namespace::autoclean;

extends 'Lab::Moose::Instrument';

with qw(
    Lab::Moose::Instrument::Common

    Lab::Moose::Instrument::SCPI::Format

    Lab::Moose::Instrument::SCPI::Sense::Bandwidth
    Lab::Moose::Instrument::SCPI::Sense::Frequency
    Lab::Moose::Instrument::SCPI::Sense::Sweep
    Lab::Moose::Instrument::SCPI::Sense::Power
    Lab::Moose::Instrument::SCPI::Display::Window
    Lab::Moose::Instrument::SCPI::Unit

    Lab::Moose::Instrument::SCPI::Initiate

    Lab::Moose::Instrument::SCPIBlock

    Lab::Moose::Instrument::DisplayXY
);

sub BUILD {
    my $self = shift;

    # limitation of hardware
    $self->capable_to_query_number_of_X_points_in_hardware(1);
    $self->capable_to_set_number_of_X_points_in_hardware(0);

    $self->clear();
    $self->cls();
    sleep 1; # for Rigol Scope we need to wait otherwise instrument is not ready
}

=head1 Driver for Rigol DS1054z scope

=head1 Hardware capabilities and presets attributes

Not all devices implemented full set of SCPI commands.
With following we can mark what is available

=head2 C<capable_to_query_number_of_X_points_in_hardware>

Can hardware report the number of points in a sweep. I.e. can it respont
to analog of C<[:SENSe]:SWEep:POINts?> command.

Default is 1, i.e true.

=head2 C<capable_to_set_number_of_X_points_in_hardware>

Can hardware set the number of points in a sweep. I.e. can it respont
to analog of C<[:SENSe]:SWEep:POINts> command.

Default is 1, i.e true.

=head2 C<hardwired_number_of_X_points>

Some hardware has fixed/unchangeable number of points in the sweep.
So we can set it here to simplify the logic of some commands.

This is not set by default.
Use C<has_hardwired_number_of_X_points> to check for its availability.

=cut

has 'capable_to_query_number_of_X_points_in_hardware' => (
    is       => 'rw',
    isa      => 'Bool',
    required => 1,
    default  => 1,
);

has 'capable_to_set_number_of_X_points_in_hardware' => (
    is       => 'rw',
    isa      => 'Bool',
    required => 1,
    default  => 1,
);

has 'hardwired_number_of_X_points' => (
    is        => 'rw',
    isa       => 'Int',
    predicate => 'has_hardwired_number_of_X_points',
);

=head1 METHODS

=head2 validate_trace_param

Validates or applies hardware friendly  aliases to trace parameter.
Trace has to be in (1..3).

=cut

sub validate_trace_param {
    my ( $self, $trace ) = @_;
    if ( $trace < 1 || $trace > 4 ) {
        confess "trace has to be in (1..4)";
    }
    return "CHANnel$trace";
}


sub    get_StartX {
    my ( $self, %args ) = @_;
    return 1;
}

sub  get_StopX {
    my ( $self, %args ) = @_;
    return 1;
}

sub get_trace_preambule {
    my ( $self, %args ) = @_;
    my $trace = delete $args{trace};
    if ( !defined $trace ) {
	    $trace = $self->validate_trace_param(1); # every scope should have Trace 1
    }
    $self->write(
        command => sprintf( ":WAVeform:SOURce  %s", $trace ),
        %args
    );
    my $reply = $self->query( command => "WAVeform:PREamble?", %args );
    #my $reply = "0,2,6000000,1,1.000000e-09,-3.000000e-03,0,4.132813e-01,0,122";
    # Format is
    # <format>,<type>,<points>,<count>,
    # <xincrement>,<xorigin>,<xreference>,
    # <yincrement>,<yorigin>,<yreference>
    # Wherein,
    # <format>: 0 (BYTE), 1 (WORD) or 2 (ASC).
    # <type>: 0 (NORMal), 1 (MAXimum) or 2 (RAW).
    # <points>: an integer between 1 and 12000000. After the memory depth option is
    #           installed, <points> is an integer between 1 and 24000000.
    # <count>: the number of averages in the average sample mode and 1 in other modes.
    # <xincrement>: the time difference between two neighboring points in the X direction.
    # <xorigin>: the start time of the waveform data in the X direction.
    # <xreference>: the reference time of the data point in the X direction.
    # <yincrement>: the waveform increment in the Y direction.
    # <yorigin>: the vertical offset relative to the "Vertical Reference Position" in the Y direction.
    # <yreference>: the vertical reference position in the Y direction.

    my ($format,$type,$points,$count,$xincrement,$xorigin,$xreference,$yincrement,$yorigin,$yreference) = split( /,/, $reply );
    my %preambule = (
	    format => $format,
	    type   => $type,
	    points => $points,
	    count  => $count,
	    xincrement => $xincrement,
	    xorigin => $xorigin,
	    xreference => $xreference,
	    yincrement => $xincrement,
	    yorigin => $xorigin,
	    yreference => $xreference,
    );
    return %preambule;
}

sub get_Xpoints_number {
    my ( $self, %args ) = @_;
    my %preambule = $self->get_trace_preambule(%args);
    return $preambule{'points'};
}

sub get_traceX {
    my ( $self, %args ) = @_;
    my %preambule = $self->get_trace_preambule(%args);
    my $num_points = $preambule{'points'};
    my $xorigin = $preambule{'xorigin'};
    my $xincrement = $preambule{'xincrement'};

    my $start = 1*$xincrement;
    my $stop  = $num_points*$xincrement;
    my $traceX     = pdl linspaced_array( $start, $stop, $num_points );
    $traceX += $xorigin;
    return $traceX;
}

sub set_aquired_trace {
    my ( $self, %args ) = validated_hash(
        \@_,
        timeout_param(),
        trace => { isa => 'Int' },
    );

    my $trace = delete $args{trace};
    $trace = $self->validate_trace_param($trace);

    $self->write( command => ":WAVEFORM:SOURCE $trace", %args );
}

sub set_waveform_mode {
    my ( $self, %args ) = validated_hash(
        \@_,
        timeout_param(),
        mode => { isa => 'Str' },
    );

    # mode can be NORMAL, MAXIMUM, RAW
    # NORMAL is 1200 points visible on the screen
    # others are tricky and need extra logic to process
    my $mode = delete $args{mode};
    if ( $mode ne 'NORMAL' ) {
	    croak("Wrong mode $mode. Modes other than NORMAL are not implemented");
    }
    $self->write( command => ":WAVEFORM:MODE NORMAL", %args );
}

sub set_waveform_format {
    my ( $self, %args ) = validated_hash(
        \@_,
        timeout_param(),
        format => { isa => 'Str' },
    );
    # Format could be 
    # - ASCII: slow read time
    # - WORD:  prefix everything with useless zero (2 bytes)
    # - BYTE: unsigned 8 bit. Gives fastest transfer rate
    my $format = delete $args{format};
    if ( $format ne 'BYTE' ) {
	    croak("Wrong format $format. Modes other than BYTE are not implemented");
    }
    $self->write( command => ":WAVEFORM:FORMAT BYTE", %args );
}

sub get_traceY {
    # grab what is on display for a given trace
    my ( $self, %args ) = validated_hash(
        \@_,
        timeout_param(),
        trace => { isa => 'Int' },
    );

    my $precision = delete $args{precision};

    # Switch to binary trace format
    #$self->set_data_format_precision( precision => $precision );

    $self->set_aquired_trace(%args);
    my $trace = delete $args{trace};

    $self->set_waveform_mode(mode=>'NORMAL', %args);
    $self->set_waveform_format(format=>'BYTE', %args);

    my %preambule = $self->get_trace_preambule(trace=>$trace, %args);

    # Get data.
    my $binary = $self->binary_query(
        command => ":WAVEFORM:DATA?",
        %args
    );

    # -------------------------------------------------------------------
    # the modified SCPIBlock/binary_to_array to extract unsigned bytes
    # fixme generalize SCPIBlock/binary_to_array 
    if ( substr( $binary, 0, 1 ) ne '#' ) {
        croak 'does not look like binary data';
    }

    my $num_digits = substr( $binary, 1, 1 );
    my $num_bytes  = substr( $binary, 2, $num_digits );
    my $expected_length = $num_bytes + $num_digits + 2;

    # $binary might have a trailing newline, so do not check for equality.
    if ( length $binary < $expected_length ) {
        croak "incomplete data: expected_length: $expected_length,"
            . " received length: ", length $binary;
    }

    my @floats = unpack(
        'C*',
        substr( $binary, 2 + $num_digits, $num_bytes )
    );
    # -------------------------------------------------------------------
    
    my $traceY = pdl @floats;
    $traceY = ($traceY - $preambule{yorigin} - $preambule{yreference})*$preambule{yincrement};
    #Vchan = (double(Vchan) - ch_cfg.yorigin - ch_cfg.yreference) * ch_cfg.yincrement;
    return $traceY;

}

sub get_traceXY {
    my ( $self, %args ) = @_;

    my $traceY = $self->get_traceY(%args);
    my $traceX = $self->get_traceX(%args);

    return cat( $traceX, $traceY );
}

sub get_NameX {
    my ( $self, %args ) = @_;
    return 'Time';
}

sub get_UnitX {
    my ( $self, %args ) = @_;
    return 'S'; # seconds
}

sub get_NameY {
    my ( $self, %args ) = @_;
    return 'Voltage';
}

sub get_UnitY {
    my ( $self, %args ) = @_;
    return 'V'; # Volt
}

sub get_log_header {
    my ( $self, %args ) = @_;
    my $date = strftime( '%Y-%m-%dT%H:%M:%S', localtime() );
    return "$date";
}

sub get_plot_title {
    my ( $self, %args ) = @_;
    my $date = strftime( '%Y-%m-%dT%H:%M:%S', localtime() );
    return "$date";
}


__PACKAGE__->meta()->make_immutable();

1;

