#!/usr/bin/perl
#
# Created by Patrick F. Marques 
# patrickfmarques AT gmail DOT com
#

use warnings;
use strict;
use Term::ANSIColor 3.0;

my $confs;

#PID confs
${$confs}{'PID' }{'COLOR'} = 'black on_bright_black';
${$confs}{'PID' }{'SPACE'} = 6;
#Priority confs
${$confs}{'PRIO' }{'V'} = 'black on_white';
${$confs}{'PRIO' }{'D'} = 'black on_blue';
${$confs}{'PRIO' }{'I'} = 'black on_green';
${$confs}{'PRIO' }{'W'} = 'black on_yellow';
${$confs}{'PRIO' }{'E'} = 'black on_red';
${$confs}{'PRIO'}{'SPACE'} = 2;
#Tag confs
${$confs}{'TAG' }{'COLOR'}{'dalvikvm'} = 'blue';
${$confs}{'TAG' }{'COLOR'}{'Process'} = 'blue';
${$confs}{'TAG' }{'COLOR'}{'ActivityManager'} = 'cyan';
${$confs}{'TAG' }{'COLOR'}{'ActivityThread'} = 'cyan';
${$confs}{'TAG' }{'SPACE'} = 20;
#Message confs
${$confs}{'MSG' }{'COLOR'}{'DEFAULT'} = '';
${$confs}{'MSG' }{'COLOR'}{'E'} = 'red';
${$confs}{'MSG' }{'SPACE'} = 0;

my @colors = qw(red green yellow blue magenta cyan white);
my $ops;

if(-t STDIN) { # No stdin try execut adb logcat
	my $pid = open(STDIN, "adb logcat $ops |") or die ("catn open adb logcat with this options $_");
	if( $#ARGV > 0 ) {
		$ops = join(' ',@ARGV);
	}
} else { # Read from stdin
}


while (<STDIN>) {
#while( <> ) {
	my $prio;
	my $tag;
	my $pid;
	my $msg;
	
	#/(.)\/(.*)\(\s*(\d*)\s*\):(.*)/ or die ("logcat format is unknown...\n'$_'\n");
	/^([A-Z])\/([^\(]+)\(([^\)]+)\): (.*)$/ or die ("logcat format is unknown...\n'$_'\n");

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

	# Hilight text messages
	if( exists ${$confs}{'MSG' }{'COLOR'}{$prio} ) {
		print colored( sprintf( " %*.*s", ${$confs}{'MSG' }{'SPACE'}, ${$confs}{'MSG' }{'SPACE'}, $msg ), ${$confs}{'MSG' }{'COLOR'}{$prio} );
	} else {                                                          
		print colored( sprintf( " %s", $msg ), ${$confs}{'MSG' }{'COLOR'}{'DEFAULT'} );
	}
	print "\n";
}
