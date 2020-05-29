; Program:     Show_Date_Time_of_File (Chapter 11, Pr 9) 
; Description: Show date and time of creation and last written
;				for give filename
; Student:     Gabriel Warkentin
; Date:        05/13/2020
; Class:       CSCI 241
; Instructor:  Mr. Ding

INCLUDE Irvine32.inc


SystemTimeToTzSpecificLocalTime PROTO, 
lpTimeZone:DWORD,
lpUniversalTime:PTR SYSTEMTIME,
lpLocalTime:PTR SYSTEMTIME


Len_filename = 256

.data
msg1 BYTE "Input your file name: ",0
msg2 BYTE " was created on: ",0
msg3 BYTE "And it was last written on: ",0
msg4 BYTE "That file was not found!",0

filename BYTE Len_filename DUP(0)

sysTimeCreated SYSTEMTIME <>
sysTimeLastWritten SYSTEMTIME <>
bytesRead DWORD ?

.code
;------------------------------------------------------------
AccessFileDateTime PROC
	LOCAL filehandle:DWORD,
	timeCreated:FILETIME,
	timeWritten:FILETIME
; Receives: EDX offset of filename,
;           ESI points to a SYSTEMTIME structure of sysTimeCreated
;           EDI points to a SYSTEMTIME structure of sysTimeLastWritten
; Returns: If successful, CF=0 and two SYSTEMTIME structures contain the file's date/time data.
;          If it fails, CF=1.
;------------------------------------------------------------ 
	INVOKE CreateFile, EDX, GENERIC_READ, DO_NOT_SHARE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp EAX, INVALID_HANDLE_VALUE
	jz L1
	mov filehandle, eax
	INVOKE GetFileTime, filehandle, ADDR timeCreated, NULL, ADDR timeWritten
	INVOKE FileTimeToSystemTime, ADDR timeCreated, esi
	INVOKE SystemTimeToTzSpecificLocalTime, NULL, esi, esi
	INVOKE FileTimeToSystemTime, ADDR timeWritten, edi
	INVOKE SystemTimeToTzSpecificLocalTime, NULL, edi, edi
	INVOKE CloseHandle, filehandle
	clc
	jmp Lret
L1:
	stc
Lret:
	ret
AccessFileDateTime ENDP


; only because you taught this just as I was turning it in
WriteDecThenSlash MACRO
	call WriteDec
	mov al, "/"
	call WriteChar
ENDM
WriteDecThenColon MACRO
	call WriteDec
	mov al, ":"
	call WriteChar
ENDM
;------------------------------------------------------------
WriteDateTime PROC datetimeAddr: PTR SYSTEMTIME
; Receives: PTR to SYSTEMTIME structure and prints to console
; Returns: nothing
;------------------------------------------------------------ 
	mov esi, datetimeAddr
	movzx eax, (SYSTEMTIME PTR [esi]).wMonth
	WriteDecThenSlash
	movzx eax, (SYSTEMTIME PTR [esi]).wDay
	WriteDecThenSlash
	movzx eax, (SYSTEMTIME PTR [esi]).wYear
	call WriteDec
	mov al, " "
	call WriteChar
	movzx eax, (SYSTEMTIME PTR [esi]).wHour
	WriteDecThenColon
	movzx eax, (SYSTEMTIME PTR [esi]).wMinute
	WriteDecThenColon
	movzx eax, (SYSTEMTIME PTR [esi]).wSecond
	call WriteDec
	ret
WriteDateTime ENDP


MainFileTime PROC
	mov edx, OFFSET msg1
	call Writestring
	mov edx, OFFSET filename
	mov ecx, Len_filename-1
	call Readstring
	mov esi, OFFSET sysTimeCreated
	mov edi, OFFSET sysTimeLastWritten
	call AccessFileDateTime
	jc Lfail
	mov edx, OFFSET filename
	Call Writestring
	mov edx, OFFSET msg2
	call WriteString
	INVOKE WriteDateTime, ADDR sysTimeCreated
	call CrLf
	mov edx, OFFSET msg3
	call WriteString
	INVOKE WriteDateTime, ADDR sysTimeLastWritten
	call CrLf
	jmp Lend
Lfail:
	mov edx, OFFSET msg4
	call WriteString
	call CrLf
Lend:
	call WaitMsg
	exit
MainFileTime ENDP

END ;MainFileTime