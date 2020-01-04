#!/usr/bin/perl
use 5.16.0;
use warnings FATAL => 'all';

use IO::Handle;
use File::Temp ();

my $base = `pwd`;
chomp $base;

my $SUB = "hw01b-solution-v2.tar.gz";
my $GRA = "hw01b-grading-v3.tar.gz";
my $DRV = "grading-driver.pl";

my $builddir = File::Temp->newdir();
system(qq{cp "$base/demo/$SUB" "$builddir"});
system(qq{cp "$base/demo/$GRA" "$builddir"});
system(qq{cp "$base/$DRV" "$builddir"});

open my $dockerfile, ">", "$builddir/Dockerfile";
$dockerfile->say(<<"EOF");
FROM systems:v1

ENV COOKIE XXcookiecookieXX
ENV SUB /var/tmp/$SUB
ENV GRA /var/tmp/$GRA
ENV TIMEOUT 60
COPY "$SUB" /var/tmp
COPY "$GRA" /var/tmp
COPY "$DRV" /var/tmp
EOF
close($dockerfile);

chdir($builddir);

system(qq{docker build . -t systems:sb-0});
system(qq{docker run --rm systems:sb-0 perl /var/tmp/$DRV| tee "$builddir/output.log"});
system(qq{docker image rm systems:sb-0});

chdir($base);


