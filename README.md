# Motivation

There are many scenarios in which user wants to read\modify\create environment variables. As of now, the only way to achieve this via PowerShell is to use dotnetcore api's.  The goal is to provide a set of cmdlets to make user's task easier.

## Specification

New cmdlets Get-EnvironmentVariable, Set-EnvironmentVariable, New-EnvironmentVariable, Add-EnvironmentVariable, Remove-EnvironmentVariable.

### Get-EnvironmentVariable

```powershell
Get-EnvironmentVariable [[-Name] <string[]>] [-ValueOnly] [-Scope {Process | Machine | User}]  [<CommonParameters>]
```

#### Short Description

This cmdlet returns an array of EnvironmentVariable objects.

* By default, the cmdlet returns the environment variables in ‘Process’ scope.

#### Parameters

-Name

* Specify the name or pattern for environment variable. The parameter should be non-null and accepts wildcard character. Parameter value is accepted from pipeline.

-ValueOnly

* Returns only the value of the environment variable.

-Scope

* Allows value from a set of 'Process', 'Machine', 'User'.
The default scope is 'Process'.
If specified, the cmdlet returns the environment variable from the mentioned scope.
On non-Windows systems, only 'Process' is allowed.

#### Output



___

### Set-EnvironmentVariable

```powershell
Set-EnvironmentVariable [-Name] <string> [[-Value] <string>] [-Force] [-PassThru] [-Scope {Process | Machine | User}] [-WhatIf] [-Confirm]  [<CommonParameters>]
```

#### Short Description

Sets new value for an existing environment variable. If the variable does not exist, then '-force' will create the variable with the specified value.

* The default scope for the cmdlet is ‘Process’.

#### Parameters

-Name

* Specify the name of the environment variable. The variable name should be non-null and must not contain wildcard character.  Parameter value is accepted from pipeline.

-Value

* New value for the environment variable. Value must not be null or empty. Parameter value is accepted from pipeline.

-Scope

* Allows value from a set of 'Process', 'Machine', 'User'. The default scope is 'Process'. If specified, the cmdlet tries to set the value of the variable in the specified scope. On non-Windows systems, only 'Process' is allowed.

-Force

* If variable does not exist and force is set to true, the variable will be generated.

-Passthru

* If set, returns an object of type EnvironmentVariable.

-Whatif

* Enabling that switch turns everything previously typed into a test, with the results of what would have happened if the commands were actually run appearing on the screen

-Confirm

* Confirm the action with user before making a permanent change.

___

### New-EnvironmentVariable

```powershell
New-EnvironmentVariable [-Name] <string> [[-Value] <string>] [-Force] [-PassThru] [-Scope {Process | Machine | User}] [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Short Description

Creates an environment variable in the specified\default scope with the specified name and value.

* The default scope for the cmdlet is 'Process'.

#### Parameters

-Name

* Specify the name of the environment variable. The variable name should be non-null and must not contain wildcard character.  Parameter value is accepted from pipeline.

-Value

* Value for the environment variable. Value must not be null or empty. Parameter value is accepted from pipeline.

-Scope

* Allows value from a set of 'Process', 'Machine', 'User'. The default scope is ‘Process’. If specified, the cmdlet tries to set the value of the variable in the specified scope. On non-Windows systems, only 'Process' is allowed.

-Force

* The cmdlet throws an error if variable with same name already exists in the specified scope. But if force is set, the variable would be overwritten.

-Passthru

* If set, returns an object of type EnvironmentVariable.

-Whatif

* Enabling that switch turns everything previously typed into a test, with the results of what would have happened if the commands were actually run appearing on the screen

-Confirm
        •  Confirm the action with user before making a permanent change.

___

### Add-EnvironmentVariable

```powershell
Add-EnvironmentVariable [-Name] <string> [-Value] <string> [-Force] [-Prepend] [-PassThru] [-Scope {Process | Machine | User}] [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Short Description

The cmdlet appends\prepends the new value to the existing value of the environment variable.

* The default scope for the cmdlet is 'Process'.

#### Parameters

-Name

* Specify the name of the environment variable. The variable name should be non-null and must not contain wildcard character.

-Value

* New value to be appended\prepended to the existing value of the environment variable. Value must not be null or empty. Parameter value is accepted from pipeline.

-Scope

* Allows value from a set of 'Process', 'Machine', 'User'. The default scope is 'Process'. If specified, the cmdlet tries to append\prepend the new value to existing value for variable in the specified scope. On non-Windows systems, only 'Process' is allowed.

-Force

* If variable does not exist and force is set to true, the variable will be generated.

-Prepend

* By default, new value will be appended to the existing value. If Prepend is set, the value will be prepended.

-Passthru

* If set, returns an object of type EnvironmentVariable.

-Whatif

* Enabling that switch turns everything previously typed into a test, with the results of what would have happened if the commands were actually run appearing on the screen

-Confirm

* Confirm the action with user before making a permanent change.

___

### Remove-EnvironmentVariable

```powershell
Remove-EnvironmentVariable [-Name] <string[]> [-Scope {Process | Machine | User}] [-WhatIf] [-Confirm]  [<CommonParameters>]
```

#### Short Description

The cmdlet removes the environment variable with the specified name from specified\default scope.

* The default scope value for the cmdlet is 'Process'.

#### Parameters

-Name

* Specify the names of the environment variables to be removed. The variable name must not be null or empty. Parameter value can have wildcard characters.

-Scope

* Allows value from a set of 'Process', 'Machine', 'User'. The default scope is 'Process'. If specified, removes the environment variable from the given scope. On non-Windows systems, only 'Process' is allowed.

-Whatif

* Enabling that switch turns everything previously typed into a test, with the results of what would have happened if the commands were actually run appearing on the screen

-Confirm

* Confirm the action with user before making a permanent change.

#### Notes

A new class EnvironmentVariable will be created

```c#
internal sealed class EnvironmentVariable
    {
        public string Name { get; } = String.Empty;
        public string Value { get; }
        public EnvironmentVariableTarget Scope; // Unix only supports 'Process' scope
        public EnvironmentVariable() { }
        public EnvironmentVariable(string name, string value) {
            this.Name = name;
            this.Value = value;
            this.Scope = EnvironmentVariableTarget.Process;
        }
        public EnvironmentVariable(string name, string value, EnvironmentVariableTarget scope)
        {
            this.Name = name;
            this.Value = value;
            this.Scope = scope;
        }
    }
```
