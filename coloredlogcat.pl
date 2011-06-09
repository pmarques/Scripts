#!/usr/bin/perl
#
# Created by Patrick F. Marques 
# patrickfmarques AT gmail DOT com
#

use warnings;
use strict;
use Term::ANSIColor 3.0;
use Term::ReadKey;
use Text::Wrap;

# Wrap on any character
$Text::Wrap::break="[.]";

# output configuration
my $confs;

# PID confs
${$confs}{'PID' }{'COLOR'} = 'black on_bright_black';
${$confs}{'PID' }{'SPACE'} = 6;
# Priority confs
${$confs}{'PRIO' }{'V'} = 'black on_white';
${$confs}{'PRIO' }{'D'} = 'black on_blue';
${$confs}{'PRIO' }{'I'} = 'black on_green';
${$confs}{'PRIO' }{'W'} = 'black on_yellow';
${$confs}{'PRIO' }{'E'} = 'black on_red';
${$confs}{'PRIO'}{'SPACE'} = 2;
# Tag confs
${$confs}{'TAG' }{'COLOR'}{'dalvikvm'} = 'blue';
${$confs}{'TAG' }{'COLOR'}{'Process'} = 'blue';
${$confs}{'TAG' }{'COLOR'}{'ActivityManager'} = 'cyan';
${$confs}{'TAG' }{'COLOR'}{'ActivityThread'} = 'cyan';
${$confs}{'TAG' }{'SPACE'} = 20;
# Message confs
${$confs}{'MSG' }{'COLOR'}{'DEFAULT'} = '';
${$confs}{'MSG' }{'COLOR'}{'E'} = 'red';
${$confs}{'MSG' }{'SPACE'} = 0;

# Circular colors to undifined tags
my @colors = qw(red green yellow blue magenta cyan white);
my $ops = '';
my $columns;
my $rows;

# Terminal size in characters
($columns, $rows) = GetTerminalSize();

# Max size of messages
my $header = ${$confs}{'PID' }{'SPACE'} + ${$confs}{'PRIO'}{'SPACE'} + ${$confs}{'TAG' }{'SPACE'} + 4;

# Break line at this position
$Text::Wrap::columns= $columns - $header;

if(-t STDIN) {
	# No stdin try execut adb logcat
	if( $#ARGV > 0 ) {
		$ops = join(' ',@ARGV);
	}
	open(STDIN, "adb $ops logcat |") or die ("catn open adb logcat with options '$ops'");
} else {
	# Read from stdin
}


while (<STDIN>) {
	my $prio;
	my $tag;
	my $pid;
	my $msg;
	my $color;
	
	/^([VDIWE])\/([^\(]+)\(([^\)]+)\):(.*)$/ or next; #die ("logcat format is unknown...\n'$_'\n");

	$prio = $1;
	$tag = $2;
	$pid = $3;
	$msg = $4;
	
	print colored( sprintf( "%*s ", ${$confs}{'PID' }{'SPACE'}, $pid ), ${$confs}{'PID' }{'COLOR'} );

	# Use "circular array" to slect tag colors
	if( not exists ${$confs}{'TAG' }{'COLOR'}{$tag} ) {
		my $color =  shift @colors;
		${$confs}{'TAG'}{'COLOR'}{$tag} = $color;
		@colors = (@colors, $color);
	}

	print colored( sprintf( "%*.*s ", ${$confs}{'TAG' }{'SPACE'}, ${$confs}{'TAG' }{'SPACE'}, $tag ), ${$confs}{'TAG' }{'COLOR'}{$tag} );

	print colored( sprintf( "%*.*s ", ${$confs}{'PRIO'}{'SPACE'}, ${$confs}{'PRIO'}{'SPACE'}, $prio), ${$confs}{'PRIO'}{$prio} );

	# Highlight text messages of errors
	if( exists ${$confs}{'MSG' }{'COLOR'}{$prio} ) {
		$color = ${$confs}{'MSG' }{'COLOR'}{$prio};
	} else {
		$color = ${$confs}{'MSG' }{'COLOR'}{'DEFAULT'};
	}
	print colored( sprintf( "%s\n", wrap("", " " x $header, $msg) ), $color);
}
