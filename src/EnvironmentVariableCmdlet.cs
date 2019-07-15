/********************************************************************++
Copyright (c) James Truher 2019.  All rights reserved.
--********************************************************************/
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using System.Management.Automation.Internal;
using System.Runtime.InteropServices;

// Some APIs are missing from System.Environment. We use System.Management.Automation.Environment as a proxy type:
//  - for missing APIs, System.Management.Automation.Environment has extension implementation.
//  - for existing APIs, System.Management.Automation.Environment redirect the call to System.Environment.
// using Environment = System.Management.Automation.Environment;
// using EnvironmentVariableTarget = System.Management.Automation.EnvironmentVariableTarget;

namespace Microsoft.PowerShell.Commands
{

    internal sealed class EnvironmentVariable
    {
        public string Name { get; }
        public string Value { get; }
        /// <summary>
        /// The intended scope of the variable
        /// </summary>
        public EnvironmentVariableTarget Scope;
        internal EnvironmentVariable() { }

        /// <summary>
        /// Initialize a new environment variable object.
        /// This the structure used to create an instance of an environment variable
        /// </summary>
        /// <param name="name">The name of the variable</param>
        /// <param name="value">The value of the variable</param>
        public EnvironmentVariable(string name, string value) {
            this.Name = name;
            this.Value = value;
            this.Scope = EnvironmentVariableTarget.Process;
        }

        /// <summary>
        /// Initialize a new environment variable object.
        /// This the structure used to create an instance of an environment variable
        /// </summary>
        /// <param name="name">The name of the variable</param>
        /// <param name="value">The value of the variable</param>
        /// <param name="scope">The scope of the variable</param>
        public EnvironmentVariable(string name, string value, EnvironmentVariableTarget scope)
        {
            this.Name = name;
            this.Value = value;
            this.Scope = scope;
        }

        /// <summary>
        /// Return the value of the environment variable
        /// </summary>
        public override string ToString()
        {
            return Value;
        }

        /// <summary>
        /// Create the variable in the environmetn in the appropriate scope
        /// </summary>
        internal void Activate()
        {
            Environment.SetEnvironmentVariable(Name, Value, Scope);
        }
    }
    /// <summary>
    /// Base class for all environment variable commands.
    ///
    /// Because -Scope is defined in EnvironmentVariableCommandBase, all derived commands
    /// must implement -Scope.
    /// </summary>

    public abstract class EnvironmentVariableCommandBase : PSCmdlet
    {
        #region Parameters

        /// <summary>
        /// Selects active scope to work with; used for all environment variable commands.
        /// </summary>
        [Parameter]
        public EnvironmentVariableTarget Scope
        {
            get {
                return scope;
            }
            set {
                if ( ! RuntimeInformation.IsOSPlatform(OSPlatform.Windows) && value != EnvironmentVariableTarget.Process )
                {
                    throw new ArgumentException("\nScopes 'User' and 'Machine' are invalid for non-Windows systems.\nSee about_EnvironmentVariable for more information");
                }
                else
                {
                    scope = value;
                }
            }
        }
        private EnvironmentVariableTarget scope = EnvironmentVariableTarget.Process;

        #endregion parameters


        #region helpers

        /// <summary>
        /// Gets the matching variable for the specified name or pattern,
        /// using the Scope parameters defined in the base class.
        /// </summary>
        ///
        /// <param name="name">
        /// The name or pattern of the variables to retrieve.
        /// </param>
        ///
        /// <param name="lookupScope">
        /// The scope to do the lookup in. If null or empty, the
        /// lookupScope defaults to 'Process'
        /// </param>
        ///
        /// <param name="wildCardAllowed">
        /// Tells if wilcard is allowed for search or not.
        /// </param>
        ///
        /// <returns>
        /// A dictionary contatining name and value of the variables
        /// matching the name, pattern or Scope.
        /// </returns>
        ///
        internal List<EnvironmentVariable> GetMatchingVariables(string name, EnvironmentVariableTarget lookupScope, bool wildCardAllowed)
        {
            List<EnvironmentVariable> result = new List<EnvironmentVariable>();
            if (String.IsNullOrEmpty(name) && wildCardAllowed)
            {
                name = "*";
            }
            WildcardPattern nameFilter =
                WildcardPattern.Get(
                name,
                WildcardOptions.IgnoreCase);
            IDictionary variableTable = Environment.GetEnvironmentVariables(lookupScope);
            if(null != variableTable)
            {
                foreach (DictionaryEntry entry in variableTable)
                {
                    string key = (string)entry.Key;
                    string value = (string)entry.Value;
                    if(nameFilter.IsMatch(key))
                    {
                        result.Add(new EnvironmentVariable(key, value, lookupScope));
                    }
                }
            }
            return result;
        }

        /// <summary>
        /// Sets the value of an existing variable or
        /// create a new variable if it does not exist.
        /// </summary>
        ///
        /// <param name="variable">
        /// The name of the variables to retrieve.
        /// </param>
        ///
        /// <param name="value">
        /// The new value of the variable
        /// </param>
        ///
        /// <param name="scope">
        ///  The scope tp create the variable.
        /// </param>
        ///
        protected void SetVariable(string variable, string value, EnvironmentVariableTarget scope)
        {
            EnvironmentVariable envvar = new EnvironmentVariable(variable, value, scope);
            envvar.Activate();
        }

        /// <summary>
        /// Set the value of an existing variable
        /// or create new variable if it does not exist already.
        /// </summary>
        ///
        /// <param name="name">
        /// The name of the variable.
        /// </param>
        ///
        /// <param name="value">
        /// new value of the variable.
        /// rules apply.
        /// </param>
        ///
        /// <param name="scope">
        /// The scope of the variable. If scope is null or empty,
        /// default scope 'Process' is used.
        /// </param>
        ///
        /// <param name="force">
        /// use force operation
        /// rules apply.
        /// </param>
        ///
        /// <param name="passthru">
        /// return the variable if PassThru is set to True.
        /// rules apply.
        /// </param>
        ///
        /// <param name="action">
        /// Name of the action which is being performed. This will
        /// be displayed to the user when whatif parameter is specified.
        /// (New Environment Variable\Set Environment Variable).
        /// </param>
        ///
        /// <param name="target">
        /// Name of the target resource being acted upon. This will
        /// be displayed to the user when whatif parameter is specified.
        /// </param>
        ///
        protected void SetVariable(string name, string value, EnvironmentVariableTarget scope, bool force, bool passthru, PSCmdlet myCmdlet)
        {
            // If Force is not specified, see if the variable already exists
            // in the specified scope. If the scope isn't specified, then
            // check to see if it exists in the current scope.
            if (!force)
            {
                List<EnvironmentVariable> varFound = GetMatchingVariables(name, scope, false);
                if ( myCmdlet is NewEnvironmentVariableCommand && varFound.Count > 0 )
                {
                    throw new IOException(name);
                }
                else if ( myCmdlet is SetEnvironmentVariableCommand && varFound.Count == 0 )
                {
                    throw new ItemNotFoundException(name);
                }
            }

            // Since the variable doesn't exist or -Force was specified,
            // Call should process to validate the set with the user.

            if (ShouldProcess(name))
            {
                EnvironmentVariable newVariable = new EnvironmentVariable(name, value, scope);
                newVariable.Activate();
                if (passthru)
                {
                    WriteObject(newVariable);
                }
            }
        }

        #endregion helpers
    }

    /// <summary>
    /// the base class for those cmdlets which set variables
    ///    Add-EnvironmentVariable
    ///    Set-EnvironmentVariable
    ///    New-EnvironmentVariable
    /// These all need a name and a value
    /// </summary>
    public abstract class EnvironmentVariableSetterCommandBase : EnvironmentVariableCommandBase
    {

        /// <summary>
        /// Name of the environment Variable to set
        /// </summary>
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = true, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string Name
        {
            get
            {
                return _name;
            }
            set
            {
                if ( ! RuntimeInformation.IsOSPlatform(OSPlatform.Windows) && WildcardPattern.ContainsWildcardCharacters(value) )
                {
                    throw new ArgumentException("Wildcard characters not allowed in variable name");
                }
                else
                {
                    _name = value;
                }
            }
        }
        private string _name;

        /// <summary>
        /// new value of the Environment Variable
        /// </summary>
        [Parameter(Position = 1, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string Value
        {
            get
            {
                return _value;
            }
            set
            {
                if ( ! RuntimeInformation.IsOSPlatform(OSPlatform.Windows) && WildcardPattern.ContainsWildcardCharacters(value) )
                {
                    throw new ArgumentException("Wildcard characters not allowed in variable name");
                }
                else
                {
                    _value = value;
                }
            }
        }
        private string _value;
    }


    /// <summary>
    /// This class implements Get-EnvironmentVariable command
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "EnvironmentVariable")]
    [OutputType(typeof(EnvironmentVariable))]
    public sealed class GetEnvironmentVariableCommand : EnvironmentVariableCommandBase
    {
        #region parameters

        /// <summary>
        /// Name of the Environment Variable
        /// </summary>
        [Parameter(Position = 0, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        [ValidateNotNull]
        public string[] Name { get; set; } = new string[] { "*" };

        /// <summary>
        /// Output only the value(s) of the requested variable(s).
        /// </summary>
        [Parameter]
        public SwitchParameter ValueOnly { get; set; }

        #endregion parameters
        /// <summary>
        /// The implementation of the Get-EnvironmentVariable command
        /// </summary>
        ///
        protected override void ProcessRecord()
        {
            foreach (string varName in Name)
            {
                List<EnvironmentVariable> matchingVariables = GetMatchingVariables(varName, Scope, true);
                matchingVariables.Sort(
                    delegate (EnvironmentVariable left, EnvironmentVariable right)
                    {
                        return StringComparer.CurrentCultureIgnoreCase.Compare(left.Name, right.Name);
                    });
                bool matchFound = false;
                foreach (EnvironmentVariable variable in matchingVariables)
                {
                    matchFound = true;
                    if (ValueOnly)
                    {
                        WriteObject(variable.Value);
                    }
                    else
                    {
                        WriteObject(variable);
                    }
                }

                if (!matchFound && ! WildcardPattern.ContainsWildcardCharacters(varName))
                {
                    WriteError(
                        new ErrorRecord(
                            new ItemNotFoundException(varName),
                            "GetVariableCommand",
                            ErrorCategory.ObjectNotFound,
                            varName));
                }
            }
        }
    }

    /// <summary>
    /// This class implements New-EnvironmentVariable command
    /// </summary>
    [Cmdlet(VerbsCommon.New, "EnvironmentVariable", SupportsShouldProcess = true, HelpUri = "http://go.microsoft.com/fwlink/?LinkID=113285")]
    [OutputType(typeof(EnvironmentVariable))]
    public sealed class NewEnvironmentVariableCommand : EnvironmentVariableSetterCommandBase
    {
        #region parameters

        /// <summary>
        /// Force the operation to make the best attempt at setting the variable.
        /// </summary>
        [Parameter]
        public SwitchParameter Force { get; set; }

        /// <summary>
        /// The variable object should be passed down the pipeline.
        /// </summary>
        [Parameter]
        public SwitchParameter PassThru { get; set; }

        #endregion parameters

        /// <summary>
        /// Add objects received on the pipeline to an ArrayList of values, to
        /// take the place of the Value parameter if none was specified on the
        /// command line.
        /// </summary>
        protected override void ProcessRecord()
        {
            SetVariable(Name, Value, Scope, Force, PassThru, this);
        }
    }

    /// <summary>
    /// This class implements Set-EnvironmentVariable command
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "EnvironmentVariable", SupportsShouldProcess = true)]
    [OutputType(typeof(EnvironmentVariable))]
    public sealed class SetEnvironmentVariableCommand : EnvironmentVariableSetterCommandBase
    {
        #region parameters

        /// <summary>
        /// Force the operation to make the best attempt at setting the variable.
        /// </summary>
        [Parameter]
        public SwitchParameter Force { get; set; }

        /// <summary>
        /// The variable object should be passed down the pipeline.
        /// </summary>
        [Parameter]
        public SwitchParameter PassThru { get; set; }

        #endregion parameters

        /// <summary>
        /// Sets the variable if the variable exists.
        /// If variable does not exist and 'Force' is not used,
        /// throw exception. If 'Force' is used, create new variable.
        /// </summary>
        protected override void ProcessRecord()
        {
            // string action = VariableCommandStrings.SetEnvironmentVariableAction;
            // string target = StringUtil.Format(VariableCommandStrings.SetEnvironmentVariableTarget, Name, Value);
            SetVariable(Name, Value, Scope, Force, PassThru, this);
        }
    }

    /// <summary>
    /// This class implements Remove-EnvironmentVariable command
    /// </summary>
    [Cmdlet(VerbsCommon.Remove, "EnvironmentVariable", SupportsShouldProcess = true)]
    [OutputType(typeof(EnvironmentVariable))]
    public sealed class RemoveEnvironmentVariableCommand : EnvironmentVariableCommandBase
    {
        #region parameters

        /// <summary>
        /// Name of the Environment Variable(s) to remove
        /// </summary>
        [Parameter(Position = 0, Mandatory = true)]
        public string[] Name { get; set; }

        #endregion parameters

        /// <summary>
        /// Removes the matching variables from the specified scope
        /// </summary>
        ///
        protected override void ProcessRecord()
        {
            // Removal of variables happens in the Process scope if the
            // scope wasn't explicitly specified by the user.
            foreach (string varName in Name)
            {
                List<EnvironmentVariable> matchingVariables = GetMatchingVariables(varName, Scope, true);

                if (matchingVariables.Count == 0)
                {
                    WriteError(
                        new ErrorRecord(new ItemNotFoundException(varName),
                                "RemoveEnvironmentVariable",
                                ErrorCategory.InvalidArgument,
                                varName)
                    );
                    continue;
                }
                foreach (EnvironmentVariable matchingVariable in matchingVariables)
                {
                    if (ShouldProcess(matchingVariable.Name))
                    {
                        // Environment Variable can be removed by
                        // setting empty value.
                        SetVariable(matchingVariable.Name, "", Scope);
                    }
                }
            }
        } // ProcessRecord
    } // RemoveEnvironmentVariableCommand

    /// <summary>
    /// This class implements Add-EnvironmentVariable command
    /// </summary>
    [Cmdlet(VerbsCommon.Add, "EnvironmentVariable", SupportsShouldProcess = true)]
    [OutputType(typeof(EnvironmentVariable))]
    public sealed class AddEnvironmentVariableCommand : EnvironmentVariableSetterCommandBase
    {
        #region parameters

        /// <summary>
        /// Force the operation to make the best attempt at creating the variable.
        /// </summary>
        [Parameter]
        public SwitchParameter Force { get; set; }

        /// <summary>
        /// The new value should be prepended to the current value.
        /// By default, the value is appended
        /// </summary>
        [Parameter]
        public SwitchParameter Prepend { get; set; }

        /// <summary>
        /// The variable object should be passed down the pipeline.
        /// </summary>
        [Parameter]
        public SwitchParameter PassThru { get; set; }

        /// <summary>
        /// The separator of the added value
        /// </summary>
        [Parameter]
        public string Separator { get; set; } = Path.PathSeparator.ToString();

        #endregion parameters

        /// <summary>
        /// Append\Prepend the new value to variable's existing value.
        /// If Variable does not exist and 'Force' is used, create new variable
        /// </summary>
        protected override void ProcessRecord()
        {
            // If Force is not specified, see if the variable already exists
            // in the specified scope.
            List<EnvironmentVariable> result = GetMatchingVariables(Name, Scope, false);
            if (!Force)
            {
                if (result.Count == 0)
                {
                    WriteError(
                        new ErrorRecord(
                            new ItemNotFoundException(Name),
                            "AddEnvironmentVariableCommand",
                            ErrorCategory.ObjectNotFound,
                            Name));
                    return;
                }
            }

            if ( result.Count == 0 && ShouldProcess(Name))
            {
                SetVariable(Name, Value, Scope);
                if (PassThru)
                {
                    WriteObject(new EnvironmentVariable(Name, Value));
                }
                return;
            }

            foreach ( EnvironmentVariable variable in result )
            {
                string newValue = Prepend ? Value + Separator + variable.Value : variable.Value + Separator + Value;
                if ( ShouldProcess(variable.Name))
                {
                    SetVariable(variable.Name, newValue, variable.Scope);
                    if (PassThru)
                    {
                        WriteObject(new EnvironmentVariable(Name, newValue));
                    }
                }
            }

        }// ProcessRecord
    } // AddEnvironmentVariableCommand

}

