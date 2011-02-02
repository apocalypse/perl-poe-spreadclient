# Declare our package
package POE::Driver::SpreadClient;
use strict; use warnings;

# Our version stuff
use vars qw( $VERSION );
$VERSION = '0.09';

# Import some stuff
use Spread;

use constant MAX_READS => 256;

sub new {
	my $type = shift;
	my $mbox = shift;
	my $self = bless \$mbox, $type;
	return $self;
}

sub get {
	my $self = shift;

	my $reads_performed = 1;
	my @buf = ();

	# read once:
	push @buf, [ Spread::receive( $$self ) ];

	# Spread::poll returns 0 if no messages pending;
	while( Spread::poll( $$self ) and ++$reads_performed <= MAX_READS ) {
		push @buf, [ Spread::receive( $$self ) ];
	}

	return [ @buf ];
}

1;
__END__
