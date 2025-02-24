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

Function Invoke-DLPValidation{
    <#
        .SYNOPSIS

        .DESCRIPTION

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Invoke-DLPValidation
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Object]$dlp_objects
    )
    Begin{
        #Set vars
        $dlp_analysis = New-Object System.Collections.Generic.List[System.Object]
        #Get Org region if not exists
        if($null -eq $O365Object.orgRegions){
            $msg = @{
                MessageData = "Getting Microsoft 365 tenant location";
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'info';
                InformationAction = $script:InformationAction;
                Tags = @('O365dlpInfo');
            }
            Write-Information @msg
            $O365Object.orgRegions = Get-OrgRegion
        }
        #Get All Sits from Object
        $all_rule_sits = $dlp_objects | Select-Object -ExpandProperty sits
    }
    Process{
        if($null -ne $O365Object.dlp -and $null -ne $O365Object.orgRegions){
            foreach($element in $O365Object.dlp.GetEnumerator()){
                $msg = @{
                    MessageData = ("Analysing {0} issues" -f $element.Name);
                    callStack = (Get-PSCallStack | Select-Object -First 1);
                    logLevel = 'info';
                    InformationAction = $script:InformationAction;
                    Tags = @('O365dlpInfo');
                }
                Write-Information @msg
                #Set var
                $sits = $null
                #Get Sits
                $selected_sits = $element.Sits | Where-Object {$_.Geo -eq $O365Object.orgRegions -or $_.Geo -eq "INTL"} | Select-Object -ExpandProperty Name
                #Get Sits from Dlp Object
                $sitTypes = @()
                foreach($sit in $all_rule_sits){
                    $match = $element.Sits | Where-Object {$_.Name -eq $sit -and ($_.Geo -eq $O365Object.orgRegions -or $_.Geo -eq "INTL")}
                    if($match){
                        $sitTypes+=$match.Name
                    }
                }
                #Compare Object
                $params = @{
                    ReferenceObject = $selected_sits;
                    DifferenceObject = $sitTypes;
                    IncludeEqual= $false;
                    ExcludeDifferent = $false;
                }
                $results = Compare-Object @params
                if($null -ne $results){
                    $sits = $results | Select-Object -ExpandProperty InputObject
                }
                #Create Dict
                $DLPObject = New-Object -TypeName PsObject -Property @{
                    controlName = $element.Name;
                    controlType = $element.Tag;
                    Sits = $sits;
                }
                #Add to array
                [void]$dlp_analysis.Add($DLPObject)
            }
        }
    }
    End{
        return $dlp_analysis
    }
}

#Invoke-DLPValidation -dlp_info $data[0].o365_secomp_dlp_compliance_info.Data[0].sits -validation_type Company_Sensitive_Information
