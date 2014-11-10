package POE::Driver::SpreadClient;

# ABSTRACT: Implements the Spread driver for POE

# Import some stuff
use Spread;

# magic number taken from Spread's MAX_READS
my $MAX_READS = 256;

sub new {
	my $type = shift;
	my $mbox = shift;
	my $self = bless \$mbox, $type;
	return $self;
}

sub get {
	my $self = shift;

	my $reads_performed = 1;
	my @buf;

	# read once:
	push @buf, [ Spread::receive( $$self ) ];

	# Spread::poll returns 0 if no messages pending;
	while( Spread::poll( $$self ) and ++$reads_performed <= $MAX_READS ) {
		push @buf, [ Spread::receive( $$self ) ];
	}

	return [ @buf ];
}

1;

=pod

=for Pod::Coverage get new

=head1 DESCRIPTION

This module implements the L<POE::Driver> interface for Spread.

=cut
