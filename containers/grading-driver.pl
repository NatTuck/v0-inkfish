#!/usr/bin/perl
use 5.16.0;
use warnings FATAL => 'all';

my $COOKIE = $ENV{'COOKIE'};
my $GRA = $ENV{'GRA'};
my $SUB = $ENV{'SUB'};

say "--- grading driver ---";
say "  SUB = $SUB";
say "  GRA = $GRA";

chdir("/home/student");
system(qq{su student -c 'tar xzvf "$GRA"'});
system(qq{su student -c 'ruby -I_grading _grading/grade.rb'});
