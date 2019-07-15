---
external help file: EnvironmentVariableCmdlet.dll-Help.xml
Module Name: EnvironmentVariableCmdlet
online version:
schema: 2.0.0
---

# Add-EnvironmentVariable

## SYNOPSIS

Append a new value to a current environment variable

## SYNTAX

```powershell
Add-EnvironmentVariable [-Force] [-Prepend] [-PassThru] [-Separator <String>] [-Name] <String>
 [-Value] <String> [-Scope <EnvironmentVariableTarget>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Add-EnvironmentVariable takes the current value of an environment variable and adds a new value, separated by the `path separator` character.
By default, new values are added to the end of the existing variable value, but values can be prepended to the value with the `-Prepend` parameter.
Depending on the scope of the variable, you may need to run `Add-EnvironmentVariable` in an elevated session.
Specifically, when creating a variable in the `machine` scope, administrator privileges are required because the Windows registry location hklm:\System\CurrentControlSet\Control\Session Manager\Environment is updated.


## EXAMPLES

### Example 1

```powershell
PS> new-environmentvariable -name test -value value1
PS> Add-EnvironmentVariable -name test -value value2
PS> $env:test
value1:value2
```

Create an environment variable with `value1` and add `value2` to it.
Note that the two values are separated by `:` which is the PathSeparator on non-Windows systems.

### Example 2

```powershell
PS> Add-EnvironmentVariable -name test2 -value value2
Add-EnvironmentVariable : test2
At line:1 char:1
+ Add-EnvironmentVariable -name test2 -value value2
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : ObjectNotFound: (test2:String) [Add-EnvironmentVariable], ItemNotFoundException
+ FullyQualifiedErrorId : AddEnvironmentVariableCommand,Microsoft.PowerShell.Commands.AddEnvironmentVariableCommand
 
PS> Add-EnvironmentVariable -name test2 -value value2 -force
PS> $env:test2
value2
```

Note how `-force` is required to create a non-existent environment variable

### Example 3

```powershell
PS> new-environmentvariable -name test -value /tmp
PS> Add-EnvironmentVariable -Name test -Value /usr/local/bin -PassThru

Name Value                 Scope
---- -----                 -----
test /tmp:/usr/local/bin Process
```

Using `-PassThru` allows you to retrieve the value directly.


## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Create a variable if one does not exist.
The provided value will be used and no separator will be added.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the variable to which a new value will be added.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru

Pass the newly modified variable object back

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prepend

Using `-Prepend` will place the new value at the beginning of the existing variable.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope

The scope of the variable. On Windows systems, three values are accepted: `Process`, `User`, and `Machine`.
On Non-Windows systems, only `Process` is permitted.
Attempts to use `User` or `Machine` on non-Windows systems will produce a parameter binding error.

```yaml
Type: EnvironmentVariableTarget
Parameter Sets: (All)
Aliases:
Accepted values: Process, User, Machine

Required: False
Position: Named
Default value: Process
Accept pipeline input: False
Accept wildcard characters: False
```

### -Separator

When combining the values of the existing variable with the new value, a separator is added between the two values.
The default value for `-Separator` is platform dependent.
On Windows systems, the default value for `-Separator` is `;`.
On Linux and MacOS systems, the default value for `-Separator` is `:`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: [System.IO.Path.PathSeparator]
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value

The value to be added to the variable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The variable is not modified.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### Microsoft.PowerShell.Commands.EnvironmentVariable

When `-PassThru` is used a `Microsoft.PowerShell.Commands.EnvironmentVariable` object is returned.

## NOTES

See also Get-EnvironmentVariable, New-EnvironmentVariable, Remove-EnvironmentVariable, Set-EnvironmentVariable

## RELATED LINKS
