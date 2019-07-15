---
external help file: EnvironmentVariableCmdlet.dll-Help.xml
Module Name: EnvironmentVariableCmdlet
online version: http://go.microsoft.com/fwlink/?LinkID=113285
schema: 2.0.0
---

# New-EnvironmentVariable

## SYNOPSIS

Create a new environment variable

## SYNTAX

```powershell
New-EnvironmentVariable [-Force] [-PassThru] [-Name] <String> [-Value] <String>
 [-Scope <EnvironmentVariableTarget>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Create a new environment variable with the supplied value.
If this variable already exists, an error will be produced, unless the `-Force` parameter is provided.
Depending on the scope of the variable, you may need to run `New-EnvironmentVariable` in an elevated session.
Specifically, when creating a variable in the `machine` scope, administrator privileges are required because the Windows registry location hklm:\System\CurrentControlSet\Control\Session Manager\Environment is updated.

## EXAMPLES

### Example 1

```powershell
PS> New-EnvironmentVariable -name Name1 -Value Value1
PS> $env:Name1
Value1
```

Create a new environment variable

### Example 2

```powershell
PS> New-EnvironmentVariable -Name Name1 -Value Value2
New-EnvironmentVariable : Name1
At line:1 char:1
+ New-EnvironmentVariable -Name Name1 -Value Value2
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : NotSpecified: (:) [New-EnvironmentVariable], IOException
+ FullyQualifiedErrorId : System.IO.IOException,Microsoft.PowerShell.Commands.NewEnvironmentVariableCommand

PS> New-EnvironmentVariable -Name Name1 -Value Value3 -Force
PS> $env:Name1
Value3
```

An error is produced when using `New-EnvironmentVariable` when the variable already exists.

### Example 3

```powershell
PS> New-EnvironmentVariable -Name Name2 -Value Value2 -Pass

Name  Value    Scope
----  -----    -----
Name2 Value2 Process
PS> $env:Name2
Value2
```

Use `-PassThru` to return the newly created variable

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

If the variable already exists, an error is returned.
Using `-Force` will set the variable to the new value.

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

The name of the variable

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

Return the newly created variable object.

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

### -Value

The value of the environment variable

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
The environment variable is not created.

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

## NOTES

See also Add-EnvironmentVariable, New-EnvironmentVariable, Remove-EnvironmentVariable, Set-EnvironmentVariable

## RELATED LINKS

[http://go.microsoft.com/fwlink/?LinkID=113285](http://go.microsoft.com/fwlink/?LinkID=113285)
