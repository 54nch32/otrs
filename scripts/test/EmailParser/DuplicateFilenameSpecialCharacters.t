# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use vars (qw($Self));
use utf8;

use Kernel::System::EmailParser;

my $Home = $Self->{ConfigObject}->Get('Home');

# test for bug#1970
my @Array = ();
## no critic
open( my $IN, "<", "$Home/scripts/test/sample/EmailParser/DuplicateFilenameSpecialCharacters.box" );
## use critic
while (<$IN>) {
    push( @Array, $_ );
}
close($IN);

# create local object
my $EmailParserObject = Kernel::System::EmailParser->new(
    %{$Self},
    Email => \@Array,
);

my @Attachments = $EmailParserObject->GetAttachments();
$Self->Is(
    scalar @Attachments,
    3,
    "Found 3 files (plain and both attachments)",
);

$Self->Is(
    $Attachments[1]->{Filename} || '',
    '[Terminology_Guide].pdf',
    "First attachment",
);

$Self->Is(
    $Attachments[2]->{Filename} || '',
    '[Terminology_Guide].pdf',
    "First attachment",
);

1;
