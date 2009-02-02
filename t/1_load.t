#!/usr/bin/perl
use strict; use warnings;

my $numtests;
BEGIN {
	$numtests = 3;

	eval "use Test::NoWarnings";
	if ( ! $@ ) {
		# increment by one
		$numtests++;

	}
}

use Test::More tests => $numtests;

use_ok( 'POE::Component::SpreadClient' );
use_ok( 'POE::Driver::SpreadClient' );
use_ok( 'POE::Filter::SpreadClient' );
