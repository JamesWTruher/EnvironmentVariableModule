#
# HelpFile         : EnvVarCmdlet.dll-Help.xml
# ImplementingType : Microsoft.PowerShell.Commands.SetEnvironmentVariableCommand
# Dll              : /Users/jimtru/bin/Module/Environment/src/bin/Debug/netstandard2.0/publish/EnvVarCmdlet.dll
# CommandName      : Set-EnvironmentVariable
#
#
# Parameter Set: __AllParameterSets
#
# Name     Type                      Mandatory   Pos PipeValue PipeName Alias
# ----     ----                      ---------   --- --------- -------- -----
# Confirm  SwitchParameter               False named     False    False cf
# Force    SwitchParameter               False named     False    False
# PassThru SwitchParameter               False named     False    False
# Scope    EnvironmentVariableTarget     False named     False    False
# WhatIf   SwitchParameter               False named     False    False wi
# Name     String                         True           False     True
# Value    String                         True            True     True
#
Describe 'Set-EnvironmentVariable' {
    BeforeAll {
        $MachineScopeHive = 'hklm:\System\CurrentControlSet\Control\Session Manager\Environment'
        $UserScopeHive = 'hkcu:\environment'
    }
    BeforeEach {
        if ( $PSVersionTable.PSVersion.Major -lt 6 ) {
            $IsWindows = $true
        }
        $varName = [guid]::NewGuid()
    }
    AfterEach {
        if ( Test-Path "env:$varName" ) {
            Remove-Item "env:$varName"
        }
        if ( $IsWindows ) {
            if ( Get-ItemProperty -Path $UserScopeHive -Name $varName -ErrorAction SilentlyContinue ) {
                Remove-ItemProperty -Path $UserScopeHive -Name ${varName}
            }
            if ( Get-ItemProperty -Path $MachineScopeHive -Name $varName -ErrorAction SilentlyContinue ) {
                Remove-ItemProperty -Path $MachineScopeHive -Name ${varName}
            }
        }
    } 

    It "Can set the value of an environment variable" {
        $value = "AbCdE"
        New-EnvironmentVariable -Name $varName -Value $value
        $newValue = "A NEW VALUE"
        Set-EnvironmentVariable -Name $varName -Value  $newValue
        Get-Content "env:$varName" | Should -BeExactly $newValue
    }

    It "Can pass back the new value of an environment variable" {
        $value = "AbCdE"
        New-EnvironmentVariable -Name $varName -Value $value
        $newValue = "A NEW VALUE"
        $result = Set-EnvironmentVariable -Name $varName -Value  $newValue -Pass
        $result.Value | Should -BeExactly $newValue
    }

    It "Will produce an error if the variable does not exist" {
        { Set-EnvironmentVariable -Name $varName -Value 1 -ea Stop } | Should -Throw -ErrorId "SessionStateException,Microsoft.PowerShell.Commands.SetEnvironmentVariableCommand"
        # check this for correctness
    }

    It "Will set a non-existant enviroment variable with -force"  {
        { Set-EnvironmentVariable -Name $varName -Value 1 -Force -ea Stop } | Should -Not -Throw
        Get-Content "env:$varName" | Should -BeExactly 1
        # check this for correctness
    }

    It "Can set an environment in User scope" -skip:(! $IsWindows) {
        ${newValue} = "BcDeF"
        New-EnvironmentVariable -scope User -Name ${varName} -Value 10
        Set-EnvironmentVariable -scope User -Name ${varName} -Value $newValue
        (Get-ItemProperty -path ${UserScopeHive} -Name ${varName}).${varName} | Should -BeExactly ${newValue}
    }
}

Describe 'Set-EnvironmentVariable elevated tests' -tag RequiresAdminOnWindows {
    BeforeAll {
        $MachineScopeHive = 'hklm:\System\CurrentControlSet\Control\Session Manager\Environment'
        $UserScopeHive = 'hkcu:\environment'
    }
    BeforeEach {
        if ( $PSVersionTable.PSVersion.Major -lt 6 ) {
            $IsWindows = $true
        }
        $varName = [guid]::NewGuid()
    }
    AfterEach {
        if ( Test-Path "env:$varName" ) {
            Remove-Item "env:$varName"
        }
        if ( $Windows ) {
            if ( Get-ItemProperty -Path $UserScopeHive -Name $varName -ErrorAction SilentlyContinue ) {
                Remove-ItemProperty -Path $UserScopeHive -Name ${varName}
            }
            if ( Get-ItemProperty -Path $MachineScopeHive -Name $varName -ErrorAction SilentlyContinue ) {
                Remove-ItemProperty -Path $MachineScopeHive -Name ${varName}
            }
        }
    } 

    It "Can set an environment in Machine scope" -skip:(! $IsWindows) {
        ${newValue} = "aBcDe"
        New-EnvironmentVariable -scope Machine -Name ${varName} -Value 10
        Set-EnvironmentVariable -scope Machine -Name ${varName} -Value $newValue
        (Get-ItemProperty -path ${MachineScopeHive} -Name ${varName}).${varName} | Should -BeExactly ${newValue}
    }
}

