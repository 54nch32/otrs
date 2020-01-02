#!/usr/bin/perl
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

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use Getopt::Std;
use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;
use Kernel::System::DB;
use Kernel::System::Time;
use Kernel::System::AuthSession;

# get options
my %Opts = ();
getopt( 'h', \%Opts );
if ( $Opts{'h'} ) {
    print "otrs.CleanUp.pl - OTRS cleanup\n";
    print "Copyright (C) 2001-2020 OTRS AG, https://otrs.com/\n";
    print "usage: otrs.CleanUp.pl \n";
    exit 1;
}

# create common objects
my %CommonObject = ();
$CommonObject{ConfigObject} = Kernel::Config->new();
$CommonObject{EncodeObject} = Kernel::System::Encode->new(%CommonObject);
$CommonObject{LogObject}    = Kernel::System::Log->new(
    LogPrefix => 'OTRS-otrs.CleanUp.pl',
    %CommonObject,
);
$CommonObject{MainObject} = Kernel::System::Main->new(%CommonObject);
$CommonObject{TimeObject} = Kernel::System::Time->new(%CommonObject);

# create tmp storage objects
$CommonObject{DBObject}          = Kernel::System::DB->new(%CommonObject);
$CommonObject{AuthSessionObject} = Kernel::System::AuthSession->new(%CommonObject);

# clean up tmp storage
print "Cleaning up LogCache ...";
if ( $CommonObject{LogObject}->CleanUp() ) {
    print " done.\n";
}
else {
    print " failed.\n";
}
print "Cleaning up SessionData...";
if ( $CommonObject{AuthSessionObject}->CleanUp() ) {
    print " done.\n";
}
else {
    print " failed.\n";
}

exit 0;
