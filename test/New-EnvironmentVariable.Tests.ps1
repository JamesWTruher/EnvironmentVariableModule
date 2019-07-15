Describe 'New-EnvironmentVariable' {

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

    It "Can create an environment variable" {
        $value = "AbCdE"
        New-EnvironmentVariable -Name $varName -Value $value
        Get-Content "env:$VarName" | Should -BeExactly $value
    }

    It "Can create an environment variable and pass back the result" {
        $value = "bCdEf"
        $result = New-EnvironmentVariable -Name $varName -Value $value -Pass
        Get-Content "env:$VarName" | Should -BeExactly $value
        $result.Value | Should -BeExactly $value
    }

    It "Will produce an error if you create a variable that already exists" {
        $value = "AbCdE"
        New-EnvironmentVariable -Name $varName -Value $value
        { New-EnvironmentVariable -Name $varName -Value $value -Ea Stop } | Should -Throw -ErrorId "System.IO.IOException,Microsoft.PowerShell.Commands.NewEnvironmentVariableCommand"
    }

    It "will overwrite an existing variable when -force is used" {
        $value = "CdEfG"
        $newValue = "A NEW VALUE"
        New-EnvironmentVariable -Name $varName -Value $value
        Get-Content "env:$VarName" | Should -BeExactly $value
        { New-EnvironmentVariable -Force -Name $varName -Value $newValue -EA STOP } | Should -Not -Throw
        Get-Content "env:$VarName" | Should -BeExactly $newValue
    }

    It "Will not create a varaible if -WhatIf is used" {
        New-EnvironmentVariable -Name $varName -Value 1 -WhatIf
        Test-Path "env:$varName" | Should -Be $false
    }

    It "Can create an environment variable in the User scope" -skip:$(!$IsWindows) {
    }
    It "Can create an environment variable in the Machine scope" -skip:$(!$IsWindows) {
    }
}
