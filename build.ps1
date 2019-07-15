# Copyright (c) James Truher 2019. All rights reserved.
# Licensed under the MIT License.

param ( [switch]$package, [switch]$test, [switch]$clean, [switch]$MakeModule )

$ModRoot = "${PSScriptRoot}"
$SrcRoot = "${ModRoot}/src"
$DocRoot = "${ModRoot}/docs"
$TstRoot = "${ModRoot}/test"
$ModName = "EnvironmentVariableCmdlet"

function Export-Module {
    $target = "${ModRoot}/${ModName}"
    if ( ! ( Test-Path $target) ) {
        $null = New-Item -type Directory ${target}
    }
    Copy-Item "${ModRoot}/${ModName}.psd1" $target -force
    Copy-Item "${SrcRoot}/bin/Debug/netstandard2.0/publish/${ModName}.dll" $target -force
    $null = New-externalhelp -path ${DocRoot} -OutputPath "${target}/en-US" -force
}

function Test-IsAdmin
{
    if ( $IsWindows ) {
        $windowsIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $windowsPrincipal = new-object 'Security.Principal.WindowsPrincipal' $windowsIdentity
        if ($windowsPrincipal.IsInRole("Administrators") -eq 1) { $true } else { $false }
    }
    else {
        $false
    }
}

if ( $clean ) {
    $null = dotnet clean
    return
}

try {
    Push-Location src
    $result = dotnet publish
    if ( ! $? ) {
        throw "$result"
    }
}
finally {
    Pop-Location
}

if ( $test ) {
    Export-Module
    try {
        Push-Location ${ModRoot}
        if ( $IsWindows ) {
            if ( Test-IsAdmin ) {
                pwsh -c "Import-Module '${ModRoot}/${ModName}'; Set-Location ${TstRoot}; Invoke-Pester"
            }
            else {
                pwsh -c "Import-Module '${ModRoot}/${ModName}'; Set-Location ${TstRoot}; Invoke-Pester -Exclude RequiresAdminOnWindows"
            }
        }
        else {
            pwsh -c "Import-Module '${ModRoot}/${ModName}'; Set-Location ${TstRoot}; Invoke-Pester"
        }
    }
    finally {
        Pop-Location
    }
}

if ( $package ) {
    dotnet pack
}


if ( $MakeModule ) {
    Export-Module
}
