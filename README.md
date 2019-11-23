
# Inkfish

![inkfish logo](https://raw.githubusercontent.com/NatTuck/inkfish/master/apps/inkfish_web/assets/static/images/inkfish.png)

[![Build
Status](https://travis-ci.com/NatTuck/inkfish.svg?branch=master)](https://travis-ci.com/NatTuck/inkfish)

Inkfish is a web-based tool for managing college courses focused on computer
programming.

## TODO

 - Add grade summary to student course/show
 - Add grade summary to reg/show, with links for staff to view student status.
 - Render footer markdown & limit length in staff/course/show.
 - Show git URL for git uploads.
 - Allow photo uploads for profile.
 - Make sure view / feedback works on single file uploads.
 - Confirm file viewer behavior with binary files.
 - Feature: Individual due date extensions

## OS Package Dependencies

(Package names for Debian 10)

 - graphicsmagick

## Testing

Inkfish relies on LDAP for user info and authenication. This means that we
need to run an LDAP server for testing.

That means some more packages:

 - slapd
 - ldap-utils

This can be started by running "test/setup.sh" from the project root.


