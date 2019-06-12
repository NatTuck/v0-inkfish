# Setup for LDAP in development

To install a local server. Take most of the defaults and
set an admin password. Domain assumed is "example.com"

```
# apt install slapd ldap-utils
# dpkg-reconfigure slapd
```

To insert the seed data:

```
$ ldapadd -x -W -D cn=admin,dc=example,dc=com -f test/test-data.ldif
Password: (as set before)
```

To check the seed data:

```
ldapsearch -x -b "ou=people,dc=example,dc=com" "(uid=bob)"
```

To change a user's password:

```
ldappasswd -x -D "cn=admin,dc=ferrus,dc=net" -W -S "uid=nat,ou=people,dc=ferrus,dc=net"
```

On Ubuntu, apparmor breaks running slapd with custom config files.

```
sudo apt install -y apparmor-utils
sudo aa-complain /usr/sbin/slapd
```


