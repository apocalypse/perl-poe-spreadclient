# Declare our package
package POE::Filter::SpreadClient;
use strict; use warnings;

# Our version stuff
use vars qw( $VERSION );
$VERSION = '0.09';

sub new {
    my $type = shift;
    my $self = bless \$type, $type;
    return $self;
}

sub get {
    my $self = shift;
    return [ @_ ];
}

1;
__END__
