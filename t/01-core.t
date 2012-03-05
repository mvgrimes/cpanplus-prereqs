#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 14;
use IO::CaptureOutput qw( capture );
use CPANPLUS::Shell qw[Default];

### TODO: test the /prereqs install
# ### Use a localized site_perl, so we can test installs
# use FindBin;
# use local::lib "$FindBin::Bin/localperl";

my $shell = CPANPLUS::Shell->new;

sub test_cmd {
    my ( $cmd, $expected_stdout, $expected_stderr, $desc ) = @_;

    my ( $stdout, $stderr );
    capture {
        $shell->dispatch_on_input(
            input          => $cmd,
            noninteractive => 1
        );
    }
    \$stdout, \$stderr;

    like $stdout, $expected_stdout, "$desc (stdout)";
    like $stderr, $expected_stderr, "$desc (stderr)";
}

### Is the plugin listed
test_cmd '/plugins', qr{/prereqs}, qr{^$}, 'Plugin listed';

### Test a Build.PL module
test_cmd '/prereqs show t/build1', qr{'stuff' was not found.*Hash::Util}s,
  qr{stuff}, 'Build.PL - show';
test_cmd '/prereqs list t/build1', qr{'stuff' was not found.*Hash::Util}s,
  qr{stuff}, 'Build.PL - list';

### Test a Makefile.PL module
test_cmd '/prereqs show t/mm1', qr{'stuff' was not found.*Hash::Util}s,
  qr{stuff}, 'Makefile.PL - show';
test_cmd '/prereqs list t/mm1', qr{'stuff' was not found.*Hash::Util}s,
  qr{stuff}, 'Makefile.PL - list';

### Test a Module::Install module
test_cmd '/prereqs show t/inc1', qr{'stuff' was not found.*Hash::Util}s,
  qr{stuff}, 'Module::Install - show';
test_cmd '/prereqs list t/inc1', qr{'stuff' was not found.*Hash::Util}s,
  qr{stuff}, 'Module::Install - list';
