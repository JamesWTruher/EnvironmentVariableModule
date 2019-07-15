---
external help file: EnvironmentVariableCmdlet.dll-Help.xml
Module Name: EnvironmentVariableCmdlet
online version: http://go.microsoft.com/fwlink/?LinkID=113285
schema: 2.0.0
---

# Set-EnvironmentVariable

## SYNOPSIS

Set the value of an environment variable

## SYNTAX

```powershell
Set-EnvironmentVariable [-Force] [-PassThru] [-Name] <String> [-Value] <String>
 [-Scope <EnvironmentVariableTarget>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Set the value of an environment variable.
If the environment variable does not exist, an error will be produced.
You can use the `-Force` parameter to override this behavior to create and set the variable.
Depending on the scope of the variable, you may need to run `Set-EnvironmentVariable` in an elevated session.
Specifically, when creating a variable in the `machine` scope, administrator privileges are required because the Windows registry location hklm:\System\CurrentControlSet\Control\Session Manager\Environment is update

## EXAMPLES

### Example 1

```powershell
PS> $env:name1
1
PS> Set-EnvironmentVariable -Name name1 -value 2
PS> $env:name1
2
```

Change the value of environment variable name1 from 1 to 2

### Example 2

```powershell
PS> Set-EnvironmentVariable -name name5 -value 5
Set-EnvironmentVariable : name5
At line:1 char:1
+ Set-EnvironmentVariable -name name5 -value 5
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : InvalidArgument: (:String) [Set-EnvironmentVariable], ItemNotFoundException
+ FullyQualifiedErrorId : SessionStateException,Microsoft.PowerShell.Commands.SetEnvironmentVariableCommand

PS> Set-EnvironmentVariable -name name5 -value 5 -force
PS> $env:name5
5
```

Use `-Force` to create and set an environment variable that does not exist

### Example 3

```powershell
PS> Set-EnvironmentVariable -name name5 -value 10 -pass

Name  Value   Scope
----  -----   -----
name5 10    Process
```

Use `-PassThru` to return the newly set variable.

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

If the environment variable does not exist, an error will be produced.
Using `-Force` will create the variable if it does not exist.

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

Return the newly set variable.

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

The value to set

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
The variable value is not changed.

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

See also Add-EnvironmentVariable, New-EnvironmentVariable, Remove-EnvironmentVariable, Get-EnvironmentVariable

## RELATED LINKS
