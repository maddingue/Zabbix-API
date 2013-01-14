use Test::More;
use Test::Exception;
use Data::Dumper;

use Zabbix::API;

use lib 't/lib';
use Zabbix::API::TestUtils;

if ($ENV{ZABBIX_SERVER}) {

    plan tests => 15;

} else {

    plan skip_all => 'Needs an URL in $ENV{ZABBIX_SERVER} to run tests.';

}

use_ok('Zabbix::API::User');

my $zabber = Zabbix::API::TestUtils::canonical_login;

ok(my $default = $zabber->fetch('User', params => { search => { alias => $ENV{ZABBIX_API_USER} } })->[0],
   '... and a user known to exist can be fetched');

isa_ok($default, 'Zabbix::API::User',
       '... and that user');

ok($default->created,
   '... and it returns true to existence tests');

my $user = Zabbix::API::User->new(root => $zabber,
                                  data => { alias => 'luser',
                                            name => 'Louis',
                                            surname => 'User' });

isa_ok($user, 'Zabbix::API::User',
       '... and a user created manually');

# use Zabbix::API::Host;
# my $existing_host = $zabber->fetch('Host', params => { search => { host => 'Zabbix Server' } })->[0];

# $macro->host($existing_host);

# ok($macro->host, '... and the macro can set its host');

# isa_ok($macro->host, 'Zabbix::API::Host',
#        '... and the host');

lives_ok(sub { $user->push }, '... and pushing a new user works');

ok($user->created, '... and the pushed user returns true to existence tests (id is '.$user->id.')');

# ok($macro->host, '... and the host survived');

# isa_ok($macro->host, 'Zabbix::API::Host',
#        '... and the host still');

$user->data->{name} = 'Louise';

$user->push;

is($user->data->{name}, 'Louise',
   '... and pushing a modified user updates its data on the server');

# testing update by collision
my $same_user = Zabbix::API::User->new(root => $zabber,
                                       data => { alias => 'luser',
                                                 name => 'Loki',
                                                 surname => 'Usurper' });

# $same_user->host($existing_host);

lives_ok(sub { $same_user->push }, '... and pushing an identical user works');

ok($same_user->created, '... and the pushed identical user returns true to existence tests');

# ok($same_macro->host, '... and the host survived');

# isa_ok($same_macro->host, 'Zabbix::API::Host',
#        '... and the host still');

$user->pull;

is($user->data->{name}, 'Loki',
   '... and the modifications on the identical user are pushed');

is($same_user->id, $user->id, '... and the identical user has the same id ('.$user->id.')');

lives_ok(sub { $user->delete }, '... and deleting a user works');

ok(!$user->created,
   '... and deleting a user removes it from the server');

ok(!$same_user->created,
   '... and the identical user is removed as well') or $same_user->delete;

eval { $zabber->logout };
