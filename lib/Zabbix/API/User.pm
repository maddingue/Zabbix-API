package Zabbix::API::User;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Zabbix::API::CRUDE/;

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{userid} = $value;
        return $self->data->{userid};

    } else {

        return $self->data->{userid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix) {

        return 'user'.$suffix;

    } else {

        return 'user';

    }

}

sub extension {

    return ( output => 'extend',
             select_usrgrps => 'refer' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { filter => { alias => $self->data->{alias} },
                                              $self->extension })};

}

sub name {

    my $self = shift;

    return $self->data->{alias} || '[no username?]';

}

sub usergroups {

    ## accessor for usergroups

    my ($self, $value) = @_;

    if (defined $value) {

        die 'Accessor usergroups called as mutator';

    } else {

        my $usergroups = $self->{root}->fetch('UserGroup', params => { usrgrpids => [ map { $_->{usrgrpid} } @{$self->data->{usrgrps}} ] });
        $self->{usergroups} = $usergroups;

        return $self->{usergroups};

    }

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::User -- Zabbix user objects

=head1 SYNOPSIS

  use Zabbix::API::User;
  # fetch a single user by login ("alias")
  my $user = $zabbix->fetch('User', params => { filter => { alias => 'luser' } })->[0];
  
  # and delete it
  $user->delete;

=head1 DESCRIPTION

Handles CRUD for Zabbix user objects.

This is a subclass of C<Zabbix::API::CRUDE>; see there for inherited methods.

=head1 METHODS

=over 4

=item usergroups()

Returns an arrayref of the user's usergroups (possibly empty) as
L<Zabbix::API::UserGroup> objects.

=item name()

Accessor for the user's name (the "alias" attribute).

=item collides()

This method returns a list of users colliding (i.e. matching) this
one. If there if more than one colliding user found the implementation
can not know on which one to perform updates and will bail out.

=back

=head1 BUGS AND ODDITIES

Apparently when logging in via the web page Zabbix does not care about
the case of your username (e.g. "admin", "Admin" and "ADMIN" will all
work).  I have not tested this for filtering/searching/colliding
users.

=head1 SEE ALSO

L<Zabbix::API::CRUDE>.

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 SFR

This library is free software; you can redistribute it and/or modify it under
the terms of the GPLv3.

=cut
