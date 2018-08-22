# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Ticket::Event::TicketFreeFieldDefault;
use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (qw(ConfigObject TicketObject LogObject UserObject CustomerUserObject SendmailObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }
    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Data Event Config UserID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }
    for (qw(TicketID)) {
        if ( !$Param{Data}->{$_} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $_ in Data!"
            );
            return;
        }
    }

    my $ConfigSettings = $Self->{ConfigObject}->Get('Ticket::TicketFreeFieldDefault');
    for ( keys %{$ConfigSettings} ) {
        my $Element = $ConfigSettings->{$_};
        if ( $Param{Event} eq $Element->{Event} ) {
            my %Ticket = $Self->{TicketObject}->TicketGet( TicketID => $Param{Data}->{TicketID} );

            # do not set default free text if already set
            next if $Ticket{ 'TicketFreeText' . $Element->{Counter} };

            # do some stuff
            $Self->{TicketObject}->TicketFreeTextSet(
                Counter  => $Element->{Counter},
                Key      => $Element->{Key},
                Value    => $Element->{Value},
                TicketID => $Param{Data}->{TicketID},
                UserID   => $Param{UserID},
            );
        }
    }
    return 1;
}

1;
