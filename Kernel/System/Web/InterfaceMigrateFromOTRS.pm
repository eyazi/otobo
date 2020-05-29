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

package Kernel::System::Web::InterfaceMigrateFromOTRS;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::System::Web::InterfaceMigrateFromOTRS - the migration web interface

=head1 DESCRIPTION

the global installer web interface

=head1 PUBLIC INTERFACE

=head2 new()

create installer web interface object

    use Kernel::System::Web::InterfaceMigrateFromOTRS;

    my $Debug = 0;
    my $Interface = Kernel::System::Web::InterfaceMigrateFromOTRS->new( Debug => $Debug );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get debug level
    $Self->{Debug} = $Param{Debug} || 0;

    $Kernel::OM->ObjectParamAdd(
        'Kernel::System::Log' => {
            LogPrefix => $Kernel::OM->Get('Kernel::Config')->Get('CGILogPrefix') || 'MigrateFromOTRS',
        },
        'Kernel::Output::HTML::Layout' => {
            InstallerOnly => 1,
        },
        'Kernel::System::Web::Request' => {
            WebRequest => $Param{WebRequest} || 0,
        },
    );

    # debug info
    if ( $Self->{Debug} ) {

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'debug',
            Message  => 'Global handle started...',
        );
    }

    return $Self;
}

=head2 Run()

execute the object

    $Interface->Run();

=cut

sub Run {
    my $Self = shift;

    # get common framework params
    my %Param;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    $Param{Action}     = $ParamObject->GetParam( Param => 'Action' )     || 'MigrateFromOTRS';
    $Param{Subaction}  = $ParamObject->GetParam( Param => 'Subaction' )  || '';
    $Param{NextScreen} = $ParamObject->GetParam( Param => 'NextScreen' ) || '';

    $Kernel::OM->ObjectParamAdd(
        'Kernel::Output::HTML::Layout' => {
            %Param,
        },
    );

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check secure mode
    if ( $Kernel::OM->Get('Kernel::Config')->Get('SecureMode') ) {
        print $LayoutObject->Header();
        print $LayoutObject->Error(
            Message => Translatable('SecureMode active!'),
            Comment => Translatable(
                'If you want to re-run the MigrateFromOTRS, disable the SecureMode in the SysConfig.'
            ),
        );
        print $LayoutObject->Footer();
    }

    # run modules if a version value exists
    elsif ( $Kernel::OM->Get('Kernel::System::Main')->Require("Kernel::Modules::$Param{Action}") ) {

        # proof of concept! - create $GenericObject
        my $GenericObject = ( 'Kernel::Modules::' . $Param{Action} )->new(
            %Param,
            Debug => $Self->{Debug},
        );

        print $GenericObject->Run();
    }

    # else print an error screen
    else {

        # create new LayoutObject with '%Param'
        print $LayoutObject->Header();
        print $LayoutObject->Error(
            Message => $LayoutObject->{LanguageObject}->Translate( 'Action "%s" not found!', $Param{Action} ),
            Comment => Translatable('Please contact the administrator.'),
        );
        print $LayoutObject->Footer();
    }

    return;
}

sub DESTROY {
    my $Self = shift;

    # debug info
    if ( $Self->{Debug} ) {

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'debug',
            Message  => 'Global handle stopped.',
        );
    }

    return 1;
}

1;

=head1 TERMS AND CONDITIONS

This software is part of the OTOBO project (L<https://otobo.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut
