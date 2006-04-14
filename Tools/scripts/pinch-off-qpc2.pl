#!/usr/bin/perl
#$Id$

use strict;
use Lab::Instrument::KnickS252;
use Lab::Instrument::HP34401A;
use Time::HiRes qw/usleep/;
use Lab::Measurement;

################################

my $start_voltage=0;
my $end_voltage=-0.1;
my $step=-1e-3;

my $knick_gpib=14;
my $hp_gpib=24;

my $v_sd=780e-3/1563;
my $amp=1e-8;    # Ithaco amplification

my $U_Kontakt=12.827;

my $sample="S5a-III (81059)";
my $title="QPC rechts oben";
my $comment=<<COMMENT;
Abgek�hlt mit +150mV.
Strom von 5 nach 13, Ithaco amp $ithaco_amp, supr 10^{-10}, rise 0.3ms, V_{SD}=$v_sd V.
Gates 3 und 6.
Hi und Lo der Kabel aufgetrennt; T�r zu, Deckel zu, Licht aus; nur Rotary, ca. 85mK.
COMMENT

################################

my $g0=7.748091733e-5;

unless (($end_voltage-$start_voltage)/$step > 0) {
    warn "This will not work: start=$start_voltage, end=$end_voltage, step=$step.\n";
    exit;
}

my $knick=new Lab::Instrument::KnickS252({
	'GPIB_board'	=> 0,
	'GPIB_address'	=> $knick_gpib,
    'gate_protect'  => 1,

	'gp_max_volt_per_second' => 0.001,
});

my $hp=new Lab::Instrument::HP34401A({
	'GPIB_address'	=> $hp_gpib,
});


my $measurement=new Lab::Measurement(
	sample			=> $sample,
	title			=> $title,
	filename_base	=> 'qpc_pinch_off',
	description		=> $comment,

    live_plot   	=> 'QPC current',
        
	columns			=> [
		{
			'unit'		  	=> 'V',
			'label'		  	=> 'Gate voltage',
			'description' 	=> 'Applied to gates via low path filter.',
		},
		{
			'unit'			=> 'V',
			'label'			=> 'Amplifier output',
			'description' 	=> "Voltage output by current amplifier set to $amp.",
		}
	],
	axes			=> [
		{
			'unit'			=> 'V',
            'expression'  	=> '$C0',
			'label'		  	=> 'Gate voltage',
            'min'           => ($start_voltage < $end_voltage) ? $start_voltage : $end_voltage,
            'max'           => ($start_voltage < $end_voltage) ? $end_voltage : $start_voltage,
			'description' 	=> 'Applied to gates via low path filter.',
		},
		{
			'unit'			=> 'A',
			'expression'	=> "\$C1*$amp",
			'label'			=> 'QPC current',
			'description'	=> 'Current through QPC',
		},
        {
            'unit'          => '2e^2/h',
            'expression'    => "(\$A1/$v_sd)/$g0)",
            'label'         => "Total conductance",
        },
        {
            'unit'          => '2e^2/h',
            'expression'    => "(1/(1/abs(\$C1)-1/$U_Kontakt)) * ($amp/($v_sd*$g0))",
            'label'         => "QPC conductance",
            'min'           => -0.1,
            'max'           => 5
        },
        
	],
    plots       	        => {
        'QPC current'    => {
            'type'          => 'line',
            'xaxis'        => 0,
            'yaxis'        => 1,
        },
        'QPC conductance'=> {
            'type'         => 'line',
            'xaxis'        => 0,
            'yaxis'        => 3,
        }
    },
);

my $stepsign=$step/abs($step);

for (my $volt=$start_voltage;$stepsign*$volt<=$stepsign*$end_voltage;$volt+=$step) {
    $knick->set_voltage($volt);
    usleep(500000);
    my $meas=$hp->read_voltage_dc(10,0.0001);
    $measurement->log_line($volt,$meas);
}

my $meta=$measurement->finish_measurement();

my $plotter=new Lab::Data::Plotter($meta);

$plotter->plot('QPC conductance');

my $a=<stdin>;
