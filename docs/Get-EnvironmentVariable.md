---
external help file: EnvironmentVariableCmdlet.dll-Help.xml
Module Name: EnvironmentVariableCmdlet
online version:
schema: 2.0.0
---

# Get-EnvironmentVariable

## SYNOPSIS

Retrieve an environment variable.

## SYNTAX

```powershell
Get-EnvironmentVariable [[-Name] <String[]>] [-ValueOnly] [-Scope <EnvironmentVariableTarget>]
 [<CommonParameters>]
```

## DESCRIPTION

Every process has an `environment block` which contains the set of environment variables and their values.
When a new process is created, the process inherits the environment variables of its parent process.
The `Get-EnvironmentVariable` cmdlet allows you to retrieve those variables rather than using the `$env:PATH` syntax or `Get-Item` cmdlet.
You can retrieve environment variables via wildcards, and optionally, you can retrieve only the value of the environment variable.

Variable Scope

While variables created in the process do not persist after the process has exited, some variables may persist after the process exits.
On Windows systems, variables may also be created in a specific `scope`, which allows variables to set for all users of a system, or only the user.

* `Process`
  * The environment variable is stored or retrieved from the environment block associated with the current process.

* `User`
  * The environment variable is stored or retrieved from the HKEY_CURRENT_USER\Environment key in the Windows operating system registry. This value may be used on Windows systems only.

* `Machine`
  * The environment variable is stored or retrieved from the HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment key in the Windows operating system registry. This value may be used on Windows systems only.

## EXAMPLES

### Example 1

```powershell
PS> get-environmentvariable
Name                       Value
----                       -----
__CF_USER_TEXT_ENCODING    0x1F5:0x0:0x0
Apple_PubSub_Socket_Render /private/tmp/com.apple.launchd.6zSQW25C9C/Render
HOME                       /Users/jimtru
LANG                       en_US.UTF-8
LOGNAME                    jimtru
PATH                       /usr/local/bin:/usr/local/bin:/usr/local/bin:/usr/local/bin:/usr/local/microsoft/powershell/6:/usr/bin:/bin:/sb…
PSModulePath               /Users/jimtru/.local/share/powershell/Modules:/usr/local/share/powershell/Modules:/usr/local/microsoft/powershe…
PWD                        /Users/jimtru
SECURITYSESSIONID          186a8
SHELL                      /bin/bash
SHLVL                      0
SSH_AUTH_SOCK              /private/tmp/com.apple.launchd.X8qlPHU7Gm/Listeners
TERM                       xterm-256color
TERM_PROGRAM               Apple_Terminal
TERM_PROGRAM_VERSION       421.2
TERM_SESSION_ID            DC63F98A-CA2E-4118-A76F-B273C39CB174
TMPDIR                     /var/folders/px/05lybgxx6mlf60qjssxyxbrm0000gn/T/
USER                       jimtru
XPC_FLAGS                  0x0
XPC_SERVICE_NAME           0
```

This retrieves all the environment variables available in the current process.

### Example 2

```powershell
PS> get-environmentvariable T*

Name                 Value                                               Scope
----                 -----                                               -----
TERM                 xterm-256color                                    Process
TERM_PROGRAM         Apple_Terminal                                    Process
TERM_PROGRAM_VERSION 421.2                                             Process
TERM_SESSION_ID      DC63F98A-CA2E-4118-A76F-B273C39CB174              Process
TMPDIR               /var/folders/px/05lybgxx6mlf60qjssxyxbrm0000gn/T/ Process
```

This retrieves all environment variables whose name has 'T' as the first letter.

### Example 3

```powershell
PS> get-environmentvariable PSModulePath

Name         Value
----         -----
PSModulePath /Users/jimtru/.local/share/powershell/Modules:/usr/local/share/powershell/Modules:/usr/local/microsoft/powershell/6/Modules:/…
```

retrieve the `PSModulePath` environment variable

### Example 4

```powershell
PS> Get-EnvironmentVariable psmodulePath -ValueOnly
/Users/jimtru/.local/share/powershell/Modules:/usr/local/share/powershell/Modules:/usr/local/microsoft/powershell/6/Modules:/Users/jimtru/bin/module:/Users/jimtru/bin/module:/Users/jimtru/bin/module:/Users/jimtru/bin/module
```

retrieve only the value of the `PSModulePath` environment variable.

## PARAMETERS

### -Name

The name of the variable.
Wildcards are supported.
Parameter names are found in a case-insensitive manner.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
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

### -ValueOnly

Return only the value of the environment variable.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### Microsoft.PowerShell.Commands.EnvironmentVariable

The EnvironmentVariable object has the following properties:

|Property Type | Property Name|
|---|---|
|String|Name|
|EnvironmentVariableTarget|Scope|
|String|Value|

## NOTES

See also Add-EnvironmentVariable, New-EnvironmentVariable, Remove-EnvironmentVariable, Set-EnvironmentVariable

## RELATED LINKS
