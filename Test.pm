package CPANPLUS::Shell::Default::Plugins::Test;

use strict;

use strict;
use warnings;
use Carp;
use Data::Dumper;
use File::Basename                  qw[basename];
use CPANPLUS::Internals::Constants;

our $VERSION = '0.03_02';

sub plugins { (
            # prereqs     => 'install_prereqs',
            prereqs2    => 'install_prereqs2',
            prereqs3    => 'install_prereqs3',
        ) };

sub install_prereqs {
    my $class   = shift;        # CPANPLUS::Shell::Default::Plugins::Prereqs
    my $shell   = shift;        # CPANPLUS::Shell::Default object
    my $cb      = shift;        # CPANPLUS::Backend object
    my $cmd     = shift;        # 'prereqs'
    my $input   = shift;        # optional dirname
    my $opts    = shift || {};  # { foo => 0, bar => 2 }

    my $dir     = File::Spec->rel2abs( defined $input ? $input : '.' );
    
    my $mod = CPANPLUS::Module::Fake->new(
                module  => basename( $dir ),
                path    => $dir,
                author  => CPANPLUS::Module::Author::Fake->new,
                package => basename( $dir ),
            );

    ### set the fetch & extract targets, so we know where to look
    $mod->status->fetch(   $dir );
    $mod->status->extract( $dir );

    ### figure out whether this module uses EU::MM or Module::Build
    ### do this manually, as we're setting the extract location ourselves.
    $mod->get_installer_type or return;

    ### run 'perl Makefile.PL' or 'M::B->new_from_context' to find the prereqs.
    $mod->prepare( %$opts ) or return;

    ### get the list of prereqs
    my $href = $mod->status->prereqs or return;
    
    ### and install them
    while( my($name, $version) = each %$href ) {
    
        ### no such module
        my $obj = $cb->module_tree( $name ) or next;
        
        ### we already have this version or better installed
        next if $obj->is_uptodate( version => $version );
     
        ### install it
        $obj->install( %$opts );
    }

    return;
}

sub install_prereqs2 {
    my $class   = shift;        # CPANPLUS::Shell::Default::Plugins::Prereqs
    my $shell   = shift;        # CPANPLUS::Shell::Default object
    my $cb      = shift;        # CPANPLUS::Backend object
    my $cmd     = shift;        # 'prereqs'
    my $input   = shift;        # optional dirname
    my $opts    = shift || {};  # { foo => 0, bar => 2 }

    my $dir     = File::Spec->rel2abs( defined $input ? $input : '.' );
    
    my $mod = CPANPLUS::Module::Fake->new(
                module  => basename( $dir ),
                path    => $dir,
                author  => CPANPLUS::Module::Author::Fake->new,
                package => basename( $dir ),
            );

    ### set the fetch & extract targets, so we know where to look
    $mod->status->fetch(   $dir );
    $mod->status->extract( $dir );

    ### figure out whether this module uses EU::MM or Module::Build
    ### do this manually, as we're setting the extract location ourselves.
    $mod->get_installer_type or return;

    ### run 'make' for this module, and install its prereqs
    ### prereq resolving is run at the 'create' stage, so just
    ### doing 'prepare' isn't good enough.
    $mod->create(
        prereq_target   =>  TARGET_INSTALL,
        %$opts,
    );
    
    return;
}

sub install_prereqs3 {
    my $class   = shift;        # CPANPLUS::Shell::Default::Plugins::Prereqs
    my $shell   = shift;        # CPANPLUS::Shell::Default object
    my $cb      = shift;        # CPANPLUS::Backend object
    my $cmd     = shift;        # 'prereqs'
    my $input   = shift;        # show|list|install [dirname]
    my $opts    = shift || {};  # { foo => 0, bar => 2 }

    ### get the operation and possble target dir.
    my( $op, $dir ) = split /\s+/, $input, 2;

    ### you want us to install, or just list?
    my $install     = {
        list    => 0,
        show    => 0,
        install => 1,
    }->{ lc $op };
    
    ### you passed an unknown operation
    unless( defined $install ) {
        print __PACKAGE__->install_prereqs_help;
        return;
    }        

    ### get the absolute path to the directory
    $dir    = File::Spec->rel2abs( defined $dir ? $dir : '.' );
    
    my $mod = CPANPLUS::Module::Fake->new(
                module  => basename( $dir ),
                path    => $dir,
                author  => CPANPLUS::Module::Author::Fake->new,
                package => basename( $dir ),
            );

    ### set the fetch & extract targets, so we know where to look
    $mod->status->fetch(   $dir );
    $mod->status->extract( $dir );

    ### figure out whether this module uses EU::MM or Module::Build
    ### do this manually, as we're setting the extract location ourselves.
    $mod->get_installer_type or return;

    if( $install ) {
        ### run 'make' for this module, and install its prereqs
        ### prereq resolving is run at the 'create' stage, so just
        ### doing 'prepare' isn't good enough.
        $mod->create(
            prereq_target   =>  TARGET_INSTALL,
            %$opts,
        );

    } else {
        ### run perl Makefile.PL/Build.PL
        $mod->prepare( %$opts ) or return;
        
        ### get the list of prereqs
        my $href = $mod->status->prereqs or return;
    
        print "Listed prerequisites:\n\n";
    
        ### and install them
        for my $name ( sort keys %$href ) {
            printf "%-30s %10s\n", $name, $href->{$name};
        }
    }
    
    return;
}

sub install_prereqs_help {
    return "    /prereqs [DIR]        # Install any missing prerequisites\n".
           "                          # listed in the Build.PL or Makefile.PL\n".
           "        DIR               # Assumes . if no DIR specified\n";

}

1;

__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CPANPLUS::Shell::Default::Plugin::Prereqs - Plugin for CPANPLUS to automate
the installation of prerequisites without installing the module

=head1 SYNOPSIS

  use CPANPLUS::Shell::Default::Plugin::Prereqs;
  
  cpanp /prereqs [dir]

=head1 DESCRIPTION

A plugin for CPANPLUS's default shell which will install any missing
prerequisites for an unpacked module. Assumes the current directory
if no directory is specified.

=head1 SEE ALSO

C<CPANPLUS>, C<CPANPLUS::Shell::Default::Plugins::HOWTO>

=head1 AUTHOR

Mark Grimes, E<lt>mgrimes@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by mgrimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
