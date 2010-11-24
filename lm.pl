#!/usr/bin/env perl

#
# List Manager is a [file] list tracking utility.
# Copyright (C) 2010 Brandon McCaig
#
# This file is part of List Manager.
#
# List Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# List Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with List Manager.  If not, see <http://www.gnu.org/licenses/>.
#

use 5.10.0;

use strict;
use warnings;

use Cwd;
use Data::Dumper;
use File::Find;

use constant
{
    LISTDIR => '.lm',
    USAGE => <<EOF
usage: lm COMMAND [ARGS]

The most commonly used lm commands are:
   add        Add files to the list.
   help       Display this message.
   init       Initialize the list.
   remove     Remove files from the list.
   status     Show the list status.

See 'lm help COMMAND' for more information on specific commands.
EOF
};

my ($subcommand, @args) = @ARGV;

unless(defined($subcommand))
{
    print STDERR USAGE;
    exit 1;
}

my %dispatch = (
    add => \&add,
    init => \&init,
    help => \&help,
    remove => \&remove,
    status => \&status
);

my $sub = $dispatch{$subcommand} || $dispatch{help};

$sub->(\@args);

sub add
{
    my %ext = (
        '.c' => 'source',
        '.cpp' => 'source',
        '.cs' => 'source',
        '.h' => 'header',
        '.hpp' => 'header',
        '.pl' => 'source',
        '.py' => 'source',
    );
    my @args = @{$_[0]};
}

sub find_list_dir
{
    return LISTDIR if -e LISTDIR;

    my $cwd = getcwd;
    my $last = $cwd;
    my $found = undef;

    while(1)
    {
        chdir '..' or last;
        my $current = getcwd;
        last if $last eq $current;
        $last = $current;

        if(-d LISTDIR)
        {
            $found = '$current/' . LISTDIR;
        }
    }

    chdir $cwd or die "Failed to return to cwd. $!";

    return $found;
}

sub help
{
    my %help = (
        add => <<EOF,
The add help.
EOF
        init => <<EOF,
The init help.
EOF
        help => <<EOF,
The help help.
EOF
        remove => <<EOF,
The remove help.
EOF
        status => <<EOF,
The status help.
EOF
        error => <<EOF
'%s' is not a command. See 'lm help'.
EOF
    );

    my @args = @{$_[0]};

    if($#args == -1)
    {
        print USAGE;
        exit 0;
    }
    elsif($#args != 0)
    {
        print STDERR "Too many arguments to subcommand 'help'.\n";
        print STDERR USAGE;
        exit 1;
    }
    else
    {
        my $subcommand = $args[0];
        my $help = $help{$subcommand} || $help{error};
        printf($help, $subcommand);
        exit 0;
    }
}

sub init
{
    if(defined(find_list_dir()))
    {
        print STDERR "List already initialized.\n";
        exit 1;
    }

    mkdir LISTDIR or die "Failed to create list directory. $!";
}

sub remove
{
    say 'remove';
}

sub status
{
    say 'status';

    unless(defined(find_list_dir()))
    {
        print STDERR "List not initialized. See 'init' subcommand.\n";
        exit 1;
    }
}

