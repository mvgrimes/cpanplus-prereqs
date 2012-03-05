#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use CPANPLUS::Shell qw[Default];

eval "use Test::Output";
plan( skip_all => ' Test::Output required to run these tests' ) if $@;
plan tests => 7;

### TODO: test the /prereqs install
# ### Use a localized site_perl, so we can test installs
# use FindBin;
# use local::lib "$FindBin::Bin/localperl";

my $shell = CPANPLUS::Shell->new;

sub test_cmd {
    my ($cmd, $stdout, $stderr, $desc) = @_;

    Test::Output::output_like(
            sub { 
                $shell->dispatch_on_input(
                    input => $cmd,
                    noninteractive => 1
                )
            },
            $stdout,
            $stderr,
            $desc
        );
}

### Is the plugin listed
test_cmd '/plugins', qr{/prereqs}, qr{^$}, 'Plugin listed';

### Test a Build.PL module
test_cmd '/prereqs show t/build1', qr{'stuff' was not found.*Hash::Util}s,
         qr{stuff}, 'Build.PL - show';
test_cmd '/prereqs list t/build1', qr{'stuff' was not found.*Hash::Util}s,
         qr{stuff}, 'Build.PL - list';

SKIP: {
    skip 'MakeMaker and Module::Instal do not play nice with Test::Output', 4;

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

}
