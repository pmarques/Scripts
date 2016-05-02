#!/usr/bin/perl
#
# Created by Patrick F. Marques 
# patrickfmarques AT gmail DOT com
#

use warnings;
use strict;
use Term::ANSIColor 3.0;

use Getopt::Long;
my ( $debug, $verbose );
GetOptions (
             "debug"      => \$debug,     # Print debug logging
             "verbose"    => \$verbose    # Verbose mode
           )
or die("Error in command line arguments\n");

if(-t STDIN) {
	# test ARGV
	open(STDIN, "$ARGV[0]") or die ("cannot open file '$ARGV[0]'");
} else {
	# Read from stdin
}

my $yy = {
	# "RL" => colored("RL" , "bright_cyan"    ),
	# "RF" => colored("RF" , "bright_red"     ),
	# "RO" => colored("RO" , "blue"           ),
	# "FC" => colored("FC" , "bright_green"   ),
	# "FD" => colored("FD" , "red"            ),
	# "CA" => colored("CA" , "bright_green"   ),
	"GET" => colored("GET" , "bright_green"   ),
	"SET" => colored("SET" , "yellow"         ),
	"DEL" => colored("DEL" , "red"            ),
	# "CO" => colored("CO" , "magenta"        ),
	# "DG" => colored("DG" , "bright_white"   ),
	"SETEX"   => colored("SETEX" ,   "yellow"         ),
	"KEYS"    => colored("KEYS" , "bright_red"     ),
	"EVALSHA" => colored("EVALSHA" , "bright_red"     )
};

my $cmds = {
	"EVALSHA" => \&__EVALSHA,
	"SET"     => \&__SET,
	"GET"     => \&__GET,
	"DEL"     => \&__GET,
	"KEYS"    => \&__GET,
};

sub ParserError {
	my $msg = shift;
	my $_m = "PARSER ERROR:";
	$_m = colored( $_m, 'blink underscore red on_bright_red');
	$_m .= " ";
	$_m .= colored( $msg, 'blink underscore red')."\n";
	print $_m;
}

sub getCMD {
	my ($key) = @_;

	# TODO we can autodetect instead of map
	# print "DEFINED __$key: ".defined(&{"__$key"})."\n";

	if ( exists $yy->{$key} ) {
		return $yy->{$key};
	} else {
		if( defined($verbose) ) {
			print ParserError( "$key is not defined!" );
		}
		return colored( $key, 'blink underscore red on_bright_red');
	}
}

sub parseCMD {
	my $cmd = shift @_;
	my @rest = @{shift @_};

	not $debug or print "\tARGS: |".join( "\n\t\t", @rest)."|\n";

	my $f = $cmds->{$cmd};
	my $p;
	if( defined $f ) {
		$p = $f->( @rest );
	} else {
		$p = join( " ", @rest);
	}

	return $p;
}

sub __EVALSHA {
	# return join( " | ", @_);

	my $script_hash = shift @_;
	my $script_n_p = shift @_;

	my @hashs = splice( @_, 0, $script_n_p);
	my @args  = @_;

	return colored($script_hash , "green" )." ".
		colored( join( " ", @hashs), "yellow" )." ".
		colored( join( " ", @args), "blue" );
}

sub __SET {
	my $hash = shift @_;
	my $val = shift @_;

	$hash = colored($hash , "green" ),
	$val  = colored($val  , "yellow"),

	return $hash." ".$val;
}

sub __GET {
	my $hash = shift @_;

	$hash = colored($hash , "green" ),

	return $hash;
}

# Force flush
$|=1;
while (<STDIN>) {
	# Remove end of line '\n'
	if( /^([^\s]+)\s
		\[
			(\d*)\s
			([^\]]*)
		\]\s
		\"
			([^\"]*?)
		\"\s
		(.*)$/x ) {
		not $verbose or print "\tDate: |$1|\n";
		not $verbose or print "\tBD:   |$2|\n";
		not $verbose or print "\tIP:   |$3|\n";
		not $verbose or print "\tCMD:  |$4|\n";

		my $date = $1;
		my $bd   = $2;
		my $ip   = $3;
		my $cmd  = uc $4;

		my @rest = ( $5 =~ m{(?<!\\)"(.*?)(?<!\\)"}g );

		printf("%s %d %s %s\n", $date,
			                    $bd,
			                    getCMD( $cmd ),
			                    parseCMD( $cmd, \@rest )
		      );                      
	} else {
		print colored( sprintf( "%s", $_ ), 'yellow' );
	}
}
