﻿# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


function Get-MonkeyTeamsGuestMessagingConfiguration {
<#
        .SYNOPSIS
		Plugin to get information about Teams guest messaging configuration

        .DESCRIPTION
		Plugin to get information about Teams guest messaging configuration

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyTeamsGuestMessagingConfiguration
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false,HelpMessage = "Background Plugin ID")]
		[string]$pluginId
	)
	begin {
		#Plugin metadata
		$monkey_metadata = @{
			Id = "teams05";
			Provider = "Microsoft365";
			Title = "Plugin to get information about Teams guest messaging configuration";
			Group = @("MicrosoftTeams");
			ServiceName = "Microsoft Teams Guest messaging configuration";
			PluginName = "Get-MonkeyTeamsGuestMessagingConfiguration";
			Docs = "https://silverhack.github.io/monkey365/"
		}
		#Getting environment
		$Environment = $O365Object.Environment
		#Get Access Token from Teams
		$access_token = $O365Object.auth_tokens.Teams
		$guest_mess_conf = $null
	}
	process {
		if ($null -ne $access_token) {
			$msg = @{
				MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId,"Microsoft 365 Teams: Guest messaging configuration",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'info';
				InformationAction = $InformationAction;
				Tags = @('TeamsGuestSettings');
			}
			Write-Information @msg
			$params = @{
				Authentication = $access_token;
				InternalPath = 'PowerShell';
				ObjectType = "TeamsGuestMessagingConfiguration";
				AdminDomain = 'common';
				Environment = $Environment;
				Method = "GET";
			}
			$guest_mess_conf = Get-TeamsObject @params
		}
	}
	end {
		if ($guest_mess_conf) {
			$guest_mess_conf.PSObject.TypeNames.Insert(0,'Monkey365.Teams.Guest.Messaging.Configuration')
			[pscustomobject]$obj = @{
				Data = $guest_mess_conf;
				Metadata = $monkey_metadata;
			}
			$returnData.o365_teams_guest_messaging_conf = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Microsoft 365 Teams: Guest messaging configuration",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'warning';
				InformationAction = $InformationAction;
				Tags = @('TeamsGuestMessagingEmptyResponse');
			}
			Write-Warning @msg
		}
	}
}
