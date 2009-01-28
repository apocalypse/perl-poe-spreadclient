#!/usr/bin/perl
use strict; use warnings;

# A sample program that "pings" a group every 2 seconds
use POE;
sub POE::Component::SpreadClient::DEBUG () { 1 }
use POE::Component::SpreadClient;
use Data::Dumper;

# Generate our states!
use base 'POE::Session::AttributeBased';

POE::Component::SpreadClient->spawn();

# Okay, create our session!
POE::Session->create(
	__PACKAGE__->inline_states(),
	'heap'	=> {},
);

# Start the kernel!
POE::Kernel->run();
exit;

sub _start : State {
	# Set our alias
	$poe_kernel->alias_set( 'displayer' );

	# Connect!
	$poe_kernel->post( 'SpreadClient' => 'connect' => 'localhost' );
}

sub _child : State {
}

sub _stop : State {
}

# Local counter
my $counter = 0;

sub do_query : State {
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

sub _sp_message : State {
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

sub _sp_admin : State {
	my( $priv_name, $type, $sender, $groups, $mess_type, $message ) = @_[ ARG0 .. ARG5 ];

	# Dumper!
	print Dumper( $priv_name, $type, $sender, $groups, $mess_type, $message );

	# All done!
	return;
}

sub _sp_connect : State {
	print "We're connected to the Spread server!\n";

	# Subscribe!
	$poe_kernel->post( 'SpreadClient' => 'subscribe' => 'chatroom' );

	# Start the stuff
	$poe_kernel->yield( 'do_query' );

	# All done!
	return;
}

sub _sp_disconnect : State {
	print "We're disconnected from the Spread server!\n";

	$_[HEAP]->{'DISCON'} = 1;

	# All done!
	return;
}

sub _sp_error : State {
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
