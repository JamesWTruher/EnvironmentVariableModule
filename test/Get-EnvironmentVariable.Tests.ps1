Describe 'Get-EnvironmentVariable' {

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

    It "Can retrieve variables from default scope" {
        $expectedValue = "aBcDeF"
        Set-Content -Path "env:$varName" -Value $expectedValue
        $varObject = Get-EnvironmentVariable -Name "$varName"
        $varObject.Name | Should -BeExactly $varName
        $varObject.Value | Should -BeExactly $expectedValue
        $varObject.Scope | Should -Be process
    }

    It "Can find multiple variables which differ only by case" -Skip:$($IsWindows) {
        $uppercaseVarName = "$varName".ToUpper()
        Set-Content -Path "env:$varName" -Value 1
        Set-Content -Path "env:$uppercaseVarName" -Value 2
        $result = Get-EnvironmentVariable -Name $varName
        $result.Count | Should -Be 2
        $expectedResult = ("$varName","$uppercaseVarName" | Sort-Object -CaseSensitive) -Join ":"
        $resultString = ($result.Name | Sort-Object -CaseSensitive) -Join ":"
        "${resultString}" | Should -BeExactly "${expectedResult}"
    }

    It "Produces an error message when asking for an explicit, non-existant variable" {
        { Get-EnvironmentVariable -Name $varName -ErrorAction stop } | Should -Throw -ErrorId "GetVariableCommand,Microsoft.PowerShell.Commands.GetEnvironmentVariableCommand"
    }

    It "Does not produce an error message when asking for an explicit, non-existant variable that has a wildcard" {
        { Get-EnvironmentVariable -Name "${varName}*" -ErrorAction stop } | Should -Not -Throw
    }

    It "Returns only the value when -Value is used" {
        $expectedValue = "dEfGhI"
        Set-Content -Path "env:$varName" -Value $expectedValue
        $varObject = Get-EnvironmentVariable -Value -Name $varName
        $varObject | Should -BeOfType "String"
        $varObject | Should -BeExactly $expectedValue
    }

    It "Can retrieve multiple variables with explicit names" {
        $expectedValue1 = "lMnOpQ"
        $expectedValue2 = "rStUv"
        $var2 = [guid]::newguid()
        Set-Content -Path "env:$varName" -Value $expectedValue1
        Set-Content -Path "env:$var2" -Value $expectedValue2
        try {
            $result = Get-EnvironmentVariable -Name $varName,$var2
        }
        finally {
            # clean up the second variable
            if ( Test-Path "env:$var2" ) {
                Remove-Item "env:$var2"
            }
        }
        $result.Count | Should -Be 2
        $resultString = ($result.Value | Sort-Object) -Join ":"
        $resultString | Should -BeExactly "${expectedValue1}:${expectedValue2}"
    }

    It "Can retrieve multiple variables with wildcard" {
        $expectedValue1 = "lMnOpQ"
        $expectedValue2 = "rStUv"
        $var2 = [guid]::newguid()
        Set-Content -Path "env:$varName" -Value $expectedValue1
        Set-Content -Path "env:$var2" -Value $expectedValue2
        try {
            $nameWithWildcard = $varName,$var2 | Foreach-Object { $_ -replace "-.*","*" }
            $result = Get-EnvironmentVariable -Name $nameWithWildCard
        }
        finally {
            # clean up the second variable
            if ( Test-Path "env:$var2" ) {
                Remove-Item "env:$var2"
            }
        }
        $result.Count | Should -Be 2
        $resultString = ($result.Value | Sort-Object) -Join ":"
        $resultString | Should -BeExactly "${expectedValue1}:${expectedValue2}"
    }

    It "Can retrieve multiple variables with explicit names" {
        $expectedValue1 = "lMnOpQ"
        $expectedValue2 = "rStUv"
        $var2 = [guid]::newguid()
        Set-Content -Path "env:$varName" -Value $expectedValue1
        Set-Content -Path "env:$var2" -Value $expectedValue2
        $result = Get-EnvironmentVariable -Name $varName,$var2
        $result.Count | Should -Be 2
        $resultString = ($result.Value | Sort-Object) -Join ":"
        $resultString | Should -BeExactly "${expectedValue1}:${expectedValue2}"
    }

    Context "Scope Tests" {

        It "Can retrieve variable in the Machine scope" -skip:(!$IsWindows) {
            $scope = "machine"
            $expectedVariable = @((Get-ItemProperty 'hklm:\System\CurrentControlSet\Control\Session Manager\Environment').psobject.properties)[0]
            $result = Get-EnvironmentVariable -Scope $scope -Name $expectedVariable.Name
            $result.Name | Should -BeExactly $expectedVariable.Name
            $result.Scope | Should -Be $scope
            $result.Value | Should -BeExactly $expectedVariable.Value
        }

        It "Can retrieve variable in the User scope" -skip:(!$IsWindows) {
            $scope = "user"
            $expectedVariable = @((Get-ItemProperty hkcu:\environment).psobject.properties)[0]
            $result = Get-EnvironmentVariable -Scope $scope -Name $expectedVariable.Name
            $result.Name | Should -BeExactly $expectedVariable.Name
            $result.Scope | Should -Be $scope
            $result.Value | Should -BeExactly $expectedVariable.Value
        }

        It "Produces an error for User scope on non-Windows" -skip:($IsWindows) {
            { Get-EnvironmentVariable -Name "badvariable" -Scope User } | Should -Throw -ErrorId "ParameterBindingFailed,Microsoft.PowerShell.Commands.GetEnvironmentVariableCommand"
        }
    }

}

Describe 'Get-EnvironmentVariable Elevated tests' -tag RequiresAdminOnWindows {

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

    It "Produces an error for Machine scope on non-Windows" -skip:($IsWindows) {
        { Get-EnvironmentVariable -Name "badvariable" -Scope Machine } | Should -Throw -ErrorId "ParameterBindingFailed,Microsoft.PowerShell.Commands.GetEnvironmentVariableCommand"
    }
}

