package POE::Filter::SpreadClient;

# ABSTRACT: Implements the Spread filter for POE

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

=pod

=for Pod::Coverage get new

=head1 DESCRIPTION

This module implements the L<POE::Filter> interface for Spread.

=cut
