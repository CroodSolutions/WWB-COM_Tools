Option Explicit

Public Module Module1

    'This one will run PS and send the output to a file.

    Sub Main
        

     Shell "PowerShell.exe -WindowStyle Hidden -Command ""SystemInfo > $env:USERPROFILE\Downloads\Output.txt""", vbNormalFocus


    End Sub
    
End Module
