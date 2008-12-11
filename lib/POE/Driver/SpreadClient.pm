# Declare our package
package POE::Driver::SpreadClient;
use strict; use warnings;

# Our version stuff
use vars qw( $VERSION );
$VERSION = (qw$LastChangedRevision: 9 $)[1];

# Import some stuff
use Spread;

sub new {
	my $type = shift;
	my $mbox = shift;
	my $self = bless \$mbox, $type;
	return $self;
}

sub get {
	my $self = shift;

	# this returns all undef if we're disconnected
	return [ [ Spread::receive( $$self ) ] ];
}

1;
__END__
