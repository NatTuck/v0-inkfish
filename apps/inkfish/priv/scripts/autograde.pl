#!/usr/bin/perl
use 5.16.0;
use warnings FATAL => 'all';

use IO::Handle;
use File::Temp ();
use File::Basename qw(basename);

my $base = `pwd`;
chomp $base;

my $COOKIE = $ENV{'COOKIE'} or die;
my $grade_id = $ENV{'GID'} or die;
my $sub_src = $ENV{'SUB'} or die;
my $gra_src = $ENV{'GRA'} or die;
my $drv_src = $ENV{'DRV'} or die;

my $SUB = basename($sub_src);
my $GRA = basename($gra_src);
my $DRV = basename($drv_src);

my $builddir = File::Temp->newdir();
system(qq{cp "$sub_src" "$builddir"});
system(qq{cp "$gra_src" "$builddir"});
system(qq{cp "$drv_src" "$builddir"});

open my $dockerfile, ">", "$builddir/Dockerfile";
$dockerfile->say(<<"EOF");
FROM systems:v1

ENV COOKIE="$COOKIE" SUB="/var/tmp/$SUB" GRA="/var/tmp/$GRA" \\
    TIMEOUT="60"

COPY "$SUB" /var/tmp
COPY "$GRA" /var/tmp
COPY "$DRV" /var/tmp
EOF
close($dockerfile);

chdir($builddir);

system(qq{docker build . -t "systems:sb-$grade_id"});
system(qq{time docker run --rm "systems:sb-$grade_id" } .
       qq{perl /var/tmp/$DRV| tee "$builddir/output.log"});
system(qq{docker image rm "systems:sb-$grade_id"});

chdir($base);


