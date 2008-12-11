#!/usr/bin/perl
package simpleClient;

# Make sure we don't do anything silly
sub POE::Kernel::ASSERT_DEFAULT   () { 1 }
#sub POE::Kernel::TRACE_DEFAULT    () { 1 }
sub POE::Session::ASSERT_DEFAULT  () { 1 }

# Standard stuff to catch errors
use strict qw(subs vars refs);				# Make sure we can't mess up
use warnings FATAL => 'all';				# Enable warnings to catch errors

# A sample program that "pings" a group every 2 seconds
use POE;
sub POE::Component::SpreadClient::DEBUG () { 1 }
use POE::Component::SpreadClient;
use Data::Dumper;

# Generate our states!
use base 'POE::Session::AttributeBased';

POE::Component::SpreadClient->spawn();

# Okay, create our session!
POE::Session::AttributeBased->create(
	'heap'	=>	{},
) or die;

# Start the kernel!
POE::Kernel->run();
exit;

sub _start : state {
	# Set our alias
	$poe_kernel->alias_set( 'displayer' );

	# Connect!
	$poe_kernel->post( 'SpreadClient' => 'connect' => 'localhost' );
}

sub _child : state {
}

sub _stop : state {
}

# Local counter
my $counter = 0;

sub do_query : state {
	# Are we even connected?
	if ( exists $_[HEAP]->{'DISCON'} ) {
		return;
	}

	# Time to stop?
	if ( $counter++ == 5 ) {
		# Die!
		$poe_kernel->post( 'SpreadClient', 'disconnect' );
	} else {
		$poe_kernel->post( 'SpreadClient' => 'publish' => 'chatroom', 'any aliens here?' );

		# Delay ourself!
		$poe_kernel->delay_set( 'do_query', 2 );
	}

	# All done!
	return;
}

sub _sp_message : state {
	my( $sender, $groups, $message ) = @_[ ARG2, ARG3, ARG5 ];

	# Simplify the groups
	my $grps = '[';
	if ( ref $groups and ref $groups eq 'ARRAY' ) {
		foreach my $g ( @$groups ) {
			$grps .= " $g -";
		}

		# Get rid of the last -
		chop $grps;
		$grps .= ']';
	} else {
		$grps = $groups;
	}

	print "$sender said to $grps: $message\n";

	# All done!
	return;
}

sub _sp_admin : state {
	my( $priv_name, $type, $sender, $groups, $mess_type, $message ) = @_[ ARG0 .. ARG5 ];

	# Dumper!
	print Dumper( $priv_name, $type, $sender, $groups, $mess_type, $message );

	# All done!
	return;
}

sub _sp_connect : state {
	print "We're connected to the Spread server!\n";

	# Subscribe!
	$poe_kernel->post( 'SpreadClient' => 'subscribe' => 'chatroom' );

	# Start the stuff
	$poe_kernel->yield( 'do_query' );

	# All done!
	return;
}

sub _sp_disconnect : state {
	print "We're disconnected from the Spread server!\n";

	$_[HEAP]->{'DISCON'} = 1;

	# All done!
	return;
}

sub _sp_error : state {
	my( $type, $sperrno, $msg, $data ) = @_[ ARG0 .. ARG3 ];

	# Handle different kinds of errors
	if ( $type eq 'CONNECT' ) {
		# $sperrno = error string
		print "connect error: $sperrno to $msg\n";

		$poe_kernel->post( 'SpreadClient', 'disconnect' );
		$_[HEAP]->{'DISCON'} = 1;
	} elsif ( $type eq 'PUBLISH' ) {
		# $sperrno = Spread errno, $msg = $groups, $data = $message
		print "publish error: $sperrno -> $msg msg:$data\n";
	} elsif ( $type eq 'SUBSCRIBE' ) {
		# $sperrno = Spread errno, $msg = $groups
		print "subscribe error: $sperrno -> $msg\n";
	}
}
