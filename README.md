# csci-241-ch11-9
Show_Date_Time_of_File

Write a procedure named AccessFileDateTime that fills a SYSTEMTIME structure with date/time stamps of a file. Pass the offset of a filename in EDX, and pass the offset of two SYSTEMTIME structures in ESI and EDI.
AccessFileDateTime
; Receives: EDX offset of filename,
;           ESI points to a SYSTEMTIME structure of sysTimeCreated
;           EDI points to a SYSTEMTIME structure of sysTimeLastWritten
; Returns: If successful, CF=0 and two SYSTEMTIME structures contain the file's date/time data.
;          If it fails, CF=1.
When you implement this function, you will need to open the file to read, get its handle, pass the handle to GetFileTime, pass its results to FileTimeToSystemTime, and close the file. You can create whenCreated and lastWritten, two FILETIME local variables as intermediate arguments. Since we are only interested in two time stamps, you can simply supply NULL for the middle argument for Last Accessed:
INVOKE GetFileTime, fileHandle, ADDR whenCreated, NULL, ADDR lastWritten
Obviously, the fileHandle here can be a local variable as well. Now write a test program that calls AccessFileDateTime, make sure it return correctly. For any error happened, set a flag like CF returned from AccessFileDateTime and let the caller check it to inform the user:
   ...
   mov	edx, OFFSET filename
   mov	ecx, Len_filename-1
   call ReadString

   mov	esi, OFFSET sysTimeCreated
   mov	edi, OFFSET sysTimeLastWritten
   call AccessFileDateTime
   JC ...
   ...
and then print out the date/time when a particular file was created and last written, such as sysTime's wMonth, wDay, until wSecond. You may need a helper PROC WriteDateTime to call twice to display two dates. WriteDateTime can be implemented either call-by-value or call-by-reference. Since SYSTEMTIME is a structure, using call-by-reference is required here, see Call-by-Value vs. Call-by-Reference:
WriteDateTime PROC datetimeAddr: PTR SYSTEMTIME
At this moment, if you run this program, you can see the result like this:
Input your file name: ch11_09.lst
ch11_09.lst was created on: 10/14/2010 9:40:31
And it was last written on: 10/28/2008 5:27:1
While comparing with the Windows file property here

ch11_09.png

You certainly notice the difference, which is the difference between UTC system time and local time. How to fix it by converting the UTC system to local time? This leaves a little more work to consider. A good reference in C/C++ can be seen at CreateFile(), GetFileTime(), FileTimeToSystemTime(), Syst... You can use SystemTimeToTzSpecificLocalTime, a Win API prototype: (See also WinAPI Reference )
BOOL WINAPI SystemTimeToTzSpecificLocalTime(
 __in_opt  LPTIME_ZONE_INFORMATION lpTimeZone,
 __in      LPSYSTEMTIME lpUniversalTime,
 __out     LPSYSTEMTIME lpLocalTime
);
Since the first parameter of a pointer to TIME_ZONE_INFORMATION will be NULL, you can simply make it as DWORD without caring about that structure type. But unfortunately, it's not defined in SmallWin.inc. In order to use it, you have to declare a PROTO in assembly language format accordingly and add it to your source code.
* Now add this last converting step to your PROC AccessFileDateTime. The final one you can try is ch11_09r.exe.

Alternative: Another way is to use FileTimeToLocalFileTime, from GetFileTime, then call FileTimeToLocalFileTime, then FileTimeToSystemTime. But please notice that there might be a bug with one hour off...
