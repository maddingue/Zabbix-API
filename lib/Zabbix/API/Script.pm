package Zabbix::API::Script;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Exporter Zabbix::API::CRUDE/;

use constant {
    SCRIPT_HOSTPERM_READ => 2,
    SCRIPT_HOSTPERM_READWRITE => 3,
};

our @EXPORT_OK = qw/
SCRIPT_HOSTPERM_READ
SCRIPT_HOSTPERM_READWRITE/;

our %EXPORT_TAGS = (
    script_hostperms => [
        qw/SCRIPT_HOSTPERM_READ
        SCRIPT_HOSTPERM_READWRITE/
    ],
);

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{scriptid} = $value;
        return $self->data->{scriptid};

    } else {

        return $self->data->{scriptid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix) {

        return 'script'.$suffix;

    } else {

        return 'script';

    }

}

sub extension {

    return ( output => 'extend',
             selectGroups => 'extend',
             selectHosts => 'extend' );


}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { filter => { name => $self->data->{name} },
                                              $self->extension })};

}

sub name {

    # mutator for name

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{name} = $value;
        return $self->data->{name};

    } else {

        return $self->data->{name} || '';

    }

}

sub command {

    # mutator for command

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{command} = $value;
        return $self->data->{command};

    } else {

        return $self->data->{command} || '';

    }

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::Script -- Zabbix script objects

=head1 SYNOPSIS

  use Zabbix::API::Script;
  
  # Create a script
  use Zabbix::API::Script qw/:script_hostperms/;
  my $script = Zabbix::API::Script->new(
      root => $zabbix,
      data => {
          name => 'nmap',
          command => '/usr/bin/nmap {HOST.CONN}',
          host_access => SCRIPT_HOSTPERM_READ,
          usrgrpid => 0,
          groupid => 0,
      },
  );
  $script->push;

=head1 DESCRIPTION

Handles CRUD for Zabbix script objects.

This is a subclass of C<Zabbix::API::CRUDE>; see there for inherited
methods.

=head1 METHODS

=over 4

=item name()

Mutator for the script's name (the "name" attribute); returns the
empty string if no description is set, for instance if the script has
not been created on the server yet.

=item command()

Mutator for the command to be run by the Zabbix server; returns the
empty string if no command is set, for instance if the script has not
been created on the server yet.

=back

=head1 EXPORTS

Some constants:

  SCRIPT_HOSTPERM_READ
  SCRIPT_HOSTPERM_READWRITE

They are not exported by default, only on request; or you could import
the C<:script_hostperms> tag.

=head1 SEE ALSO

L<Zabbix::API::CRUDE>.

=head1 AUTHOR

Ray Link; maintained by Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 SFR

This library is free software; you can redistribute it and/or modify it under
the terms of the GPLv3.

=cut
