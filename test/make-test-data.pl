#!/usr/bin/perl
use 5.20.0;
use warnings FATAL => 'all';

my $uid = 500;

sub user {
    my ($name) = @_;
    ++$uid;
    my $first = ucfirst($name);
    my $ldif = <<"USER";
    dn: uid=$name,ou=people,dc=example,dc=com
    uid: $name
    cn: $name
    objectClass: inetOrgPerson
    objectClass: posixAccount
    objectClass: top
    loginShell: /bin/bash
    uidNumber: $uid
    gidNumber: 120
    homeDirectory: /home/$name
    gecos: $first Anderson,,,,
    mail: $name\@example.com
    givenName: $first
    sn: Anderson
    displayName: $first Anderson
    userPassword: {SSHA}AIzygLSXlArhAMzddUriXQxf7UlkqopP
    # userpassword: {CLEARTEXT}test
USER
    $ldif =~ s/^\s+//mg;
    return $ldif;
}

say <<"TREE";
#dn: dc=example,dc=com
#objectClass: dcObject
#objectClass: organization
#dc: Example
#o: Example

dn: ou=people,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: people
TREE


my @names = qw(alice bob carol dave erin frank gail hank);

for my $name (@names) {
    say user($name);
}
