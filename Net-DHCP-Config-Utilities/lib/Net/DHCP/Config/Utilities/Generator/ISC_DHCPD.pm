package Net::DHCP::Config::Utilities::Generator::ISC_DHCPD;

use 5.006;
use strict;
use warnings;

=head1 NAME

Net::DHCP::Config::Utilities::Generator::ISC_DHCPD - Generators a config from the supplied subnets.

=head1 VERSION

Version 0.0.1

=cut

our $VERSION = '0.0.1';


=head1 SYNOPSIS

    use Net::DHCP::Config::Utilities::Generator::ISC_DHCPD;

    my $options={
                 };
    
    my $generator = Net::DHCP::Config::Utilities::Subnet->new( $options );


=head1 METHODS

=head2 new

This initiates the object.

    my $options={
                 };
    
    my $generator = Net::DHCP::Config::Utilities::Generator::ISC_DHCPD->new( $options );

=cut

sub new {
	my %args;
	if ( defined( $_[1] ) ){
		%args=%{$_[1]};
	}

	my $self={
			  };
	bless $self;

	return $self;
}

=head1 AUTHOR

Zane C. Bowers-Hadley, C<< <vvelox at vvelox.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-dhcp-config-utilities at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-DHCP-Config-Utilities>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::DHCP::Config::Utilities


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-DHCP-Config-Utilities>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-DHCP-Config-Utilities>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Net-DHCP-Config-Utilities>

=item * Search CPAN

L<https://metacpan.org/release/Net-DHCP-Config-Utilities>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2019 by Zane C. Bowers-Hadley.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of Net::DHCP::Config::Utilities
