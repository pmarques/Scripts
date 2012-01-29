#!/usr/bin/perl
#
# Created by Patrick F. Marques 
# patrickfmarques AT gmail DOT com
#

use warnings;
use strict;
use Term::ANSIColor 3;

while( <STDIN> ) {
	/(.*\s*.*\s.*)\s(.*)\sdhclient:(.*)/ or next;
	
	print colored( sprintf( "%*s ", 0, $1 ), 'red' );
	print colored( sprintf( "%*s ", 0, $2 ), 'yellow' );
	print colored( sprintf( "%*s ", 0, $3 ), 'green' );
	print "\n";
}
