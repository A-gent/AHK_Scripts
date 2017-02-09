﻿; ===============================================================================================================================
; Get a list of all open IPv4 ports
; ===============================================================================================================================

GetTcpTable()
{
    static hIPHLPAPI := DllCall("LoadLibrary", "str", "iphlpapi.dll", "ptr"), table := []
    VarSetCapacity(MTT, 4 + (s := (20 * 32)), 0)
    while (DllCall("iphlpapi\GetTcpTable", "ptr", &MTT, "uint*", s, "uint", 1) = 122)
        VarSetCapacity(MTT, 4 + s, 0)

    table := {}, index := 1
    loop % NumGet(MTT, 0, "uint") {
        o := 4 + ((index - 1) * 20)
        table[index, "LocalIP"]    := ((MTR := NumGet(MTT, o+4, "uint"))&0xff) "." ((MTR&0xff00)>>8) "." ((MTR&0xff0000)>>16) "." ((MTR&0xff000000)>>24)
        table[index, "LocalPort"]  := ((((MTR := NumGet(MTT, o+8, "uint"))&0xff00) >> 8) | ((MTR&0xff) << 8))
        table[index, "RemoteIP"]   := ((MTR := NumGet(MTT, o+12, "uint"))&0xff) "." ((MTR&0xff00)>>8) "." ((MTR&0xff0000)>>16) "." ((MTR&0xff000000)>>24)
        table[index, "RemotePort"] := ((((MTR := NumGet(MTT, o+16, "uint"))&0xff00) >> 8) | ((MTR&0xff) << 8))
        table[index, "State"]      := NumGet(MTT, o, "uint"), index++
    }
    return table, DllCall("FreeLibrary", "ptr", hIPHLPAPI)
}

; ===============================================================================================================================

for i, v in GetTcpTable()
    MsgBox % v.LocalIP ":" v.LocalPort "   ->   " v.RemoteIP ":" v.RemotePort "    (" v.State ")"
; 192.168.0.1:445    ->    8.8.8.8:445    (2)

ExitApp

/* ===============================================================================================================================
Referenz:
- https://msdn.microsoft.com/en-us/library/aa366026(v=vs.85).aspx    GetTcpTable function
- https://msdn.microsoft.com/en-us/library/aa366917(v=vs.85).aspx    MIB_TCPTABLE structure
- https://msdn.microsoft.com/en-us/library/aa366909(v=vs.85).aspx    MIB_TCPROW structure

State-Codes:
- CLOSED         1
- LISTEN         2
- SYN_SENT       3
- SYN_RCVD       4
- ESTAB          5
- FIN_WAIT1      6
- FIN_WAIT2      7
- CLOSE_WAIT     8
- CLOSING        9
- LAST_ACK      10
- TIME_WAIT     11
- DELETE_TCB    12

=============================================================================================================================== */