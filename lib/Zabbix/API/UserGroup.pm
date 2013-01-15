package Zabbix::API::UserGroup;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Zabbix::API::CRUDE/;

use Zabbix::API::User;

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{usrgrpid} = $value;
        return $self->data->{usrgrpid};

    } else {

        return $self->data->{usrgrpid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix and $suffix =~ m/ids?/) {

        return 'usrgrp'.$suffix;

    } elsif ($suffix) {

        return 'usergroup'.$suffix;

    } else {

        return 'usergroup';

    }

}

sub extension {

    return ( output => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { filter => { name => $self->data->{name} },
                                              $self->extension })};

}

sub name {

    my $self = shift;

    return $self->data->{name} || '[no user group name?]';

}

sub users {

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{users} = $value;
        return $self->data->{users};

    } else {

        my $users = $self->{root}->fetch('User', params => { usrgrpids => [ $self->id ] });
        $self->{users} = $users;

        return $self->{users};

    }

}

sub push {

    # override CRUDE's push()

    my ($self, $data) = @_;

    $data //= $self->data;

    foreach my $user (@{$data->{users}}) {

        if (exists $user->{user}) {

            if (eval { $user->{user}->isa('Zabbix::API::User') }) {

                $user->{user}->push;
                $user->{userid} = $user->{user}->id;

            } else {

                croak 'Type mismatch: user attribute should be an instance of Zabbix::API::User';

            }

        }

    }

    # copying the anonymous hashes so we can delete stuff without touching the
    # originals
    my $users_copy = [ map { { %{$_} } } @{$data->{users}} ];

    foreach my $user (@{$users_copy}) {

        delete $user->{user};

    }

    # copying the data hashref so we can replace its users with the fake
    my $data_copy = { %{$data} };

    # the old switcheroo
    $data_copy->{users} = $users_copy;

    return $self->SUPER::push($data_copy);

}

sub pull {

    # override CRUDE's pull()

    my ($self, $data) = @_;

    if (defined $data) {

        $self->{data} = $data;

    } else {

        my %stash = map { $_->id => $_ } grep { eval { $_->isa('Zabbix::API::User') } } @{$self->users};

        $self->SUPER::pull;

        ## no critic (ProhibitCommaSeparatedStatements)
        # restore stashed items that have been removed by pulling
        $self->users(
            [map {
                { %{$_},
                  user =>
                      $stash{$_->{userid}} // Zabbix::API::User->new(root => $self->{root},
                                                                     data => { userid => $_->{userid} })->pull
                }
             }
             @{$self->users}]
            );
        ## use critic

    }

    return $self;

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::HostGroup -- Zabbix group objects

=head1 SYNOPSIS

  use Zabbix::API::HostGroup;

  my $group = $zabbix->fetch(...);

  $group->delete;

=head1 DESCRIPTION

Handles CRUD for Zabbix group objects.

This is a very simple subclass of C<Zabbix::API::CRUDE>.  Only the required
methods are implemented (and in a very simple fashion on top of that).

=head1 METHODS

=over 4

=item name()

Accessor for the hostgroup's name (the "name" attribute); returns the empty
string if no name is set, for instance if the hostgroup has not been created on
the server yet.

=item hosts()

Accessor for the hostgroup's hosts.

=back

=head1 SEE ALSO

L<Zabbix::API::CRUDE>.

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 SFR

This library is free software; you can redistribute it and/or modify it under
the terms of the GPLv3.

=cut
