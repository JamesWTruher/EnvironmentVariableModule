Describe 'Remove-EnvironmentVariable' {
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

    It "Can remove an environment variable" {
        Set-Content "env:$varName" -Value "aBcDe"
        Get-EnvironmentVariable -Value -Name $varName | Should -BeExactly aBcDe
        Remove-EnvironmentVariable -Name $varName
        Test-Path "env:$varName" | Should -Be $false
    }

    It "Won't remove a variable if -WhatIf is used" {
        $expectedValue = "BcDeF"
        Set-Content "env:$varName" -Value $expectedValue
        Remove-EnvironmentVariable -Name $varName -WhatIf
        Test-Path "env:$varName" | Should -Be $true
        Get-EnvironmentVariable -Name $varName -Value | Should -Be $expectedValue
    }

    It "Should produce an error if User scope is provided on non-Windows" -skip:$IsWindows {
        { Remove-EnvironmentVariable -Name "badvariable" -Scope User } | Should -Throw -ErrorId "ParameterBindingFailed,Microsoft.PowerShell.Commands.RemoveEnvironmentVariableCommand"
    }

    It "Should remove multiple variables using explicit names" {
        $var1 = "${varName}001"
        $var2 = "${varName}002"
        Set-Content "env:$var1" -Value 1
        Set-Content "env:$var2" -Value 2
        Test-Path "env:$var1" | Should -Be $true
        Test-Path "env:$var2" | Should -Be $true
        Remove-EnvironmentVariable -Name $var1,$var2
        Test-Path "env:$var1" | Should -Be $false
        Test-Path "env:$var2" | Should -Be $false
    }

    It "Should remove multiple variables using wildcards" {
        $var1 = "${varName}001"
        $var2 = "${varName}002"
        Set-Content "env:$var1" -Value 1
        Set-Content "env:$var2" -Value 2
        Test-Path "env:$var1" | Should -Be $true
        Test-Path "env:$var2" | Should -Be $true
        Remove-EnvironmentVariable -Name "${varName}*"
        Test-Path "env:$var1" | Should -Be $false
        Test-Path "env:$var2" | Should -Be $false
    }

    It "Should not remove anything extra" {
        $before = ((get-childitem env:).Name|Sort-Object) -join ":"
        Set-Content "env:$varName" -value 1
        Test-Path "env:$varName" | Should -Be $true
        Remove-EnvironmentVariable -Name $varName
        $after = ((get-childitem env:).Name|Sort-Object) -join ":"
        $after | Should -BeExactly $before
    }

    It "Can remove an environment in Machine scope" -skip:(! $IsWindows) {
    }

    It "Can remove an environment in User scope" -skip:(! $IsWindows) {
    }
}

Describe 'Remove-EnvironmentVariable elevated tests' -tag RequiresAdminOnWindows {
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

    It "Should produce an error if Machine scope is provided on non-Windows"  -skip:$IsWindows {
        { Remove-EnvironmentVariable -Name "badvariable" -Scope Machine } | Should -Throw -ErrorId "ParameterBindingFailed,Microsoft.PowerShell.Commands.RemoveEnvironmentVariableCommand"
    }
}
