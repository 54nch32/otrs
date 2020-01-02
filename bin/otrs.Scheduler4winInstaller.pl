#!/usr/bin/perl -w
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;

## nofilter(TidyAll::Plugin::OTRS::Perl::SyntaxCheck)

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);

use Getopt::Std;
use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;

# get options
my %Opts = ();
getopt( 'ha', \%Opts );

BEGIN {

    # check if is running on windows
    if ( $^O ne "MSWin32" ) {
        print "This program only works on Microsoft Windows!\n";
        exit 1;
    }
}

# load Windows specific modules
use Win32::Daemon;

# installing and removing of services requires Administrator permissions
require Win32;

if ( !Win32::IsAdminUser() ) {
    print "To be able to install or remove the Scheduler, call the script with UAC enabled.\n";
    print "(right-click CMD, select \'Run as administrator\').\n";
    exit 2;
}

# help option
if ( $Opts{h} ) {
    _help();
    exit 1;
}

# get current diretory
my $WorkDir = $RealBin;

# convert to Windows directory format
$WorkDir =~ s/\//\\/g;

# to store the service configuration
my %ServiceConfig = (
    name        => "OTRSScheduler",
    display     => "OTRS Scheduler",
    description => 'The OTRS Scheduler service for Windows',
    path        => $^X,
    user        => '',
    passwd      => '',
    parameters  => '"' . $WorkDir . '\otrs.Scheduler4win.pl' . '" -a servicestart',
);

# check if remove request is sent
if ( $Opts{a} && $Opts{a} eq 'remove' ) {

    # remove the service form the system
    if ( Win32::Daemon::DeleteService( $ServiceConfig{name} ) ) {
        print "The '$ServiceConfig{display}' service was successfully removed.\n";
    }

    # otherwise send last error
    else {
        print "Failed to remove '$ServiceConfig{display}' service\n";
        print "Error:";
        print Win32::FormatMessage( Win32::Daemon::GetLastError() ), "\n";
    }
    exit;
}

# check if install request is sent
elsif ( $Opts{a} && $Opts{a} eq 'install' ) {

    # install the service in the system
    if ( Win32::Daemon::CreateService( \%ServiceConfig ) ) {
        print "The '$ServiceConfig{display}' service was successfully installed.\n";
    }

    # otherwise send last error
    else {
        print "Failed to add '$ServiceConfig{display}' service\n";
        print "Error:";
        print Win32::FormatMessage( Win32::Daemon::GetLastError() ), "\n";
    }
}

# invalid option, show help
else {
    _help();
}

# Internal
sub _help {
    print "otrs.Scheduler4WinInstaller.pl - OTRS Scheduler daemon\n";
    print "Copyright (C) 2001-2020 OTRS AG, https://otrs.com/\n";
    print "usage: otrs.Scheduler4WinInstaller.pl -a <ACTION> (install|remove) ";
}
