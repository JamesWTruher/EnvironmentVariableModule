# Copyright (c) James Truher 2019. All rights reserved.
# Licensed under the MIT License.
#

@{
    RootModule = './EnvironmentVariableCmdlet.dll'
    ModuleVersion = '0.0.1'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    GUID = '60c22a9f-3c9f-43a9-b31f-fd962a4b1250'
    Author = 'James Truher'
    CompanyName = 'James Truher'
    Copyright = '(c) James Truher 2019. All rights reserved.'
    Description = 'Cmdlets to aid in manipulating environment variables'
    FunctionsToExport = @()
    CmdletsToExport = @(
        "Get-EnvironmentVariable",
        "New-EnvironmentVariable",
        "Set-EnvironmentVariable",
        "Add-EnvironmentVariable",
        "Remove-EnvironmentVariable"
        )
    VariablesToExport = @()
    AliasesToExport = @()

    PrivateData = @{
        PSData = @{
        }
    }
}

