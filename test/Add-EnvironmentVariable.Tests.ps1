Describe 'Add-EnvironmentVariable' {

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

    It "Can append a value to an environment variable" {
        Set-Item -Path "env:$varName" -Value "initial value"
        Add-EnvironmentVariable -Name $varName -Value additionalValue
        $expectedValue = "initial value{0}additionalValue" -f ([System.IO.Path]::PathSeparator)
        Get-Content "env:${varName}" | Should -BeExactly $expectedValue
    }

    It "Can prepend a value to an environment variable" {
        Set-Item -Path "env:$varName" -Value "initial value"
        Add-EnvironmentVariable -Name $varName -Value additionalValue -Prepend
        $expectedValue = "additionalValue{0}initial value" -f ([System.IO.Path]::PathSeparator)
        Get-Content "env:${varName}" | Should -BeExactly $expectedValue
    }

    It "Produces an error if -scope machine is used on non-Windows platforms" {
        { Add-EnvironmentVariable -Name $varName -Value}
    }

    It "Fails to add a value to an environment variable if it doesn't exist" {
        { Add-EnvironmentVariable -Name $varName -Value additionalValue -ErrorAction Stop } | Should -Throw
    }

    It "Creates a value for an environment variable if it doesn't exist and force is used" {
        Add-EnvironmentVariable -Name $varName -Value "myValue" -Force
        Get-Content "env:${varName}" | Should -BeExactly "myValue"
    }

}

Describe "Add-EnvironmentVariable elevated tests" -Tag 'RequiresAdminOnWindows' {
    BeforeAll {
        $MachineScopeHive = 'hklm:\System\CurrentControlSet\Control\Session Manager\Environment'
        $UserScopeHive = 'hkcu:\environment'
        if ( $PSVersionTable.PSVersion.Major -lt 6 ) {
            $IsWindows = $true
        }
    }
    BeforeEach {
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

    It "Can append a value to a machine scope variable" -skip:(!$IsWindows) {
        $value1 = "cDeFg"
        $value2 = "HiJkL"
        $expectedValue = $value1,$value2 -join ([io.path]::PathSeparator)
        New-EnvironmentVariable -Scope machine -Name ${varName} -Value $value1
        Add-EnvironmentVariable -Scope machine -Name ${varName} -Value $value2
        Get-EnvironmentVariable -Scope machine -Name ${varName} -ValueOnly | Should -BeExactly $expectedValue
    }

}