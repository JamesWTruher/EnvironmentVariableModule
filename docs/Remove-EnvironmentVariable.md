---
external help file: EnvironmentVariableCmdlet.dll-Help.xml
Module Name: EnvironmentVariableCmdlet
online version: http://go.microsoft.com/fwlink/?LinkID=113285
schema: 2.0.0
---

# Remove-EnvironmentVariable

## SYNOPSIS

Remove an environment variable.

## SYNTAX

```powershell
Remove-EnvironmentVariable [-Name] <String[]> [-Scope <EnvironmentVariableTarget>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Remove an environment variable from a scope.
Depending on the scope of the variable, you may need to run `Add-EnvironmentVariable` in an elevated session.
Specifically, when creating a variable in the `machine` scope, administrator privileges are required because the Windows registry location hklm:\System\CurrentControlSet\Control\Session Manager\Environment is updated

## EXAMPLES

### Example 1

```powershell
PS> $env:Variable1 = "value1"
PS> $env:Variable2 = "value2"
PS> $env:Variable3 = "value3"
PS> $env:Variable1
value1
PS> Remove-EnvironmentVariable -Name Variable1
PS> $env:Variable1
PS>
```

Remove a variable

### Example 2

```powershell
PS> $env:Variable2 = "value2"
PS> $env:Variable3 = "value3"
PS> Remove-EnvironmentVariable -Name Variable2,Variable3
PS> $env:Variable2
PS> $env:Variable3
```

Remove a collection of variables

### Example 3

```powershell
PS> $env:Variable1 = "Value1"
PS> $env:Variable2 = "Value2"
PS> $env:Variable3 = "Value3"
PS> get-childitem env:variable*

Name                           Value
----                           -----
Variable2                      Value2
Variable3                      Value3
Variable1                      Value1

PS> Remove-EnvironmentVariable -Name Variable*
PS> get-childitem env:variable*
PS>
```

Remove a number of variables via a `wildcard`

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

### -Name

The name(s) of the variable(s) to remove.
Wildcards are supported.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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

### -WhatIf

Shows what would happen if the cmdlet runs.
The variables are not removed.

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

### None

## OUTPUTS

### None

## NOTES

See also Add-EnvironmentVariable, New-EnvironmentVariable, Get-EnvironmentVariable, Set-EnvironmentVariable

## RELATED LINKS
