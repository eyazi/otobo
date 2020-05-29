# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2020 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package Kernel::Modules::AgentDaemonInfo;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # set home directory
    my $Home = $Kernel::OM->Get('Kernel::Config')->Get('Home');

    my %Data = (
        DaemonCron     => $Home . '/var/cron/otobo_daemon',
        CronExecutable => $Home . '/bin/Cron.sh',
    );

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Output = $LayoutObject->Output(
        TemplateFile => 'AgentDaemonInfo',
        Data         => {
            %Param,
            %Data,
        },
    );
    return $LayoutObject->Attachment(
        NoCache     => 1,
        ContentType => 'text/html',
        Charset     => $LayoutObject->{UserCharset},
        Content     => $Output,
        Type        => 'inline'
    );
}

1;
