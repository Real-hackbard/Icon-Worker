unit untUtils;

interface

uses Windows, WinSock;

{
  Normal in CommCtrl deklariert
}
type
  TOpenFilename = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PAnsiChar;
    lpstrCustomFilter: PAnsiChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PAnsiChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PAnsiChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PAnsiChar;
    lpstrTitle: PAnsiChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PAnsiChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
    pvReserved: Pointer;
    dwReserved: DWORD;
    FlagsEx: DWORD;
  end;

function IntToStr(i: Integer): String;
function StrToInt(S: String): Integer;
function FloatToStr(E: Extended): String;
function StrToFloat(S: String): Extended;
function IntToHex(dwNumber: DWORD): String; overload;
function IntToHex(dwNumber: DWORD; Len: Integer): String; overload;
function HexToInt(S: String): Integer;

function LowerString(S: String): String;
function UpperString(S: String): String;
function Trim(S: String): String;
function FirstDelimiter(S: String; Delimiter: Char): Integer;
function LastDelimiter(S: String; Delimiter: Char): Integer;
function ReplaceChar(S: String; Old, New: Char): String;
function ReplaceString(S, OldPattern, NewPattern: String): String;
function Format(sFormat: String; Args: Array of const): String;
function Split(Input, Deliminator: String; Index: Integer): String;

function ExtractFilePath(sFilename: String): String;
function ExtractFileName(sFilename: String): String;
function ExtractFileExt(sFilename: String): String;
function ExtractDriveName(sFilename: String): String;
function ExtractURLSite(S: String): String;
function ExtractURLPath(S: String): String;
function ExtractMyFilename: String;
function ExtractMyFilePath: String;

function FormatTime(MilliSec: Cardinal): String;
function GetFileDateTime(lpFilename: String): String;
function FormatBytes(sNumber: String): String; overload;
function FormatBytes(Number: Integer): String; overload;
function TranslateSize(Size: TLargeInteger): String;
function GetFileSize(FileName: String): DWORD;
function GetFileSizeFormated(FileName: String): String;
function FileExists(FileName: String): Boolean;
function DirectoryExists(DirectoryName: String): Boolean;
function DeleteFolder(Path: String): Boolean;
function GetFileVersionInfo(Filename, BlockKey: String): String;

function GetLastErrorMsg: String;
function GetWindowsVersion: String;
function IsWindows9x: Boolean;
function IsWindowsNt: Boolean;
function GetWindowsDirectory: String;
function GetSystemDirectory: String;
function GetTempDirectory: String;
function GetUsername: String;
function GetComputername: String;
function GetWindowsUpTime: String;

function DownloadFileFromNet(sURL, sDestination: String): Boolean;
function SetDebugPrivilege: Boolean;
function GetDefaultBrowser: String;
function GetEnvironmentValue(Value: String): String;
function ExtractResource(lpFilename: String; lpName, lpType: PChar): Boolean;
function GetResourceData(lpName, lpType: PChar; var dwResSize: DWORD): Pointer;
function GetFileData(lpFilename: String; var dwFileSize: DWORD): Pointer;
function SaveToFile(lpFilename: String; lpBuffer: Pointer; Size: DWORD = INVALID_HANDLE_VALUE): Boolean;
function GetEOFData(lpFilename: String; var lpBuffer: Pointer; var dwLength: Cardinal): Boolean;
function OpenFile(hParent: THandle; Filter, Title: String; var lpFilename: String): Boolean;
function SaveFile(hParent: THandle; Filter, Title: String; var lpFilename: String): Boolean;
procedure ProcessMessages;
procedure XorEncrypt(lpBuffer: Pointer; Count, Key: DWORD);
function XorEncryptStr(sBuffer: String; Key: DWORD): String;
function GetPointerSize(lpBuffer: Pointer): Cardinal;
function MyGetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC;
function MyLoadLibrary(lpLibFileName: PAnsiChar): HMODULE;

function ShowMessage(Text: String; Caption: String = 'Utils'; uType: Cardinal = MB_ICONINFORMATION): Integer;
function ShowMessageIcon(Text: String; Caption: String = 'Utils'; lpdwStyle: Cardinal = MB_OK or MB_USERICON): Integer;
function wsprintf(var Output; Format: PChar): Integer; cdecl; varargs; external user32 name 'wsprintfA';
function GetOpenFileName(var OpenFile: TOpenFilename): Bool; stdcall; external 'comdlg32.dll' name 'GetOpenFileNameA';
function GetSaveFileName(var OpenFile: TOpenFilename): Bool; stdcall; external 'comdlg32.dll'  name 'GetSaveFileNameA';

const
  lpEnter = #13#10;

implementation

const
  OFN_HIDEREADONLY = $00000004;
  OFN_PATHMUSTEXIST = $00000800;
  OFN_FILEMUSTEXIST = $00001000;

function ShowMessage(Text: String; Caption: String = 'Utils'; uType: Cardinal = MB_ICONINFORMATION): Integer;
begin
  Result := MessageBox(0, PChar(Text), PChar(Caption), uType);
end;

function ShowMessageIcon(Text: String; Caption: String = 'Utils'; lpdwStyle: Cardinal = MB_OK or MB_USERICON): Integer;
var
  MsgBoxParams: TMsgBoxParams;
begin
  ZeroMemory(@MsgBoxParams, sizeof(TMsgBoxParams));
  with MsgBoxParams do
  begin
    cbSize := sizeof(TMsgBoxParams);
    hwndOwner := 0;
    hInstance := SysInit.hInstance;
    lpszText := PChar(Text);
    lpszCaption := PChar(Caption);
    dwStyle := lpdwStyle;
    PWChar(lpszIcon) := 'MAINICON';
    dwContextHelpId := 0;
    lpfnMsgBoxCallback := nil;
    dwLanguageId := LANG_ENGLISH;
  end;
  Result := Integer(MessageBoxIndirect(MsgBoxParams));
end;

function IntToStr(i: Integer): String;
begin
  Str(i, Result);
end;

function StrToInt(S: String): Integer;
begin
  Val(S, Result, Result);
end;

function FloatToStr(E: Extended): String;
begin
  Str(E:2:2, Result);
  Result := ReplaceChar(Result, '.', ',');
end;

function StrToFloat(S: String): Extended;
var
  I: Integer;
begin
  Val(S, Result, I);
end;

function IntToHex(dwNumber: DWORD): String; overload;
const
  HexNumbers:Array [0..15] of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                                      'A', 'B', 'C', 'D', 'E', 'F');
begin
  Result := '';
  while dwNumber <> 0 do
  begin
    Result := HexNumbers[Abs(dwNumber mod 16)] + Result;
    dwNumber := dwNumber div 16;
  end;
  if Result = '' then
  begin
    Result := '00000000';
    Exit;
  end;
  if Result[Length(Result)] = '-' then
  begin
    Delete(Result, Length(Result), 1);
    Insert('-', Result, 1);
  end;
  while Length(Result) < sizeof(dwNumber) do
    Result := '0' + Result;
end;

function IntToHex(dwNumber: DWORD; Len: Integer): String; overload;
const
  HexNumbers:Array [0..15] of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                                      'A', 'B', 'C', 'D', 'E', 'F');
begin
  Result := '';
  while dwNumber <> 0 do
  begin
    Result := HexNumbers[Abs(dwNumber mod 16)] + Result;
    dwNumber := dwNumber div 16;
  end;
  if Result = '' then
  begin
    while Length(Result) < Len do
      Result := '0' + Result;
    Exit;
  end;
  if Result[Length(Result)] = '-' then
  begin
    Delete(Result, Length(Result), 1);
    Insert('-', Result, 1);
  end;
  while Length(Result) < Len do
    Result := '0' + Result;
end;

function HexToInt(S: String): Integer;
begin
  Result := StrToInt('$' + S);
end;

function LowerString(S: String): String;
var
  i: Integer;
begin
  for i := 1 to Length(S) do
    S[i] := char(CharLower(PChar(S[i])));
  Result := S;
end;

function UpperString(S: String): String;
var
  i: Integer;
begin
  for i := 1 to Length(S) do
    S[i] := char(CharUpper(PChar(S[i])));
  Result := S;
end;

function Trim(S: String): String;
var
  i: Integer;
begin
  for i := 0 to Length(S) do
    if (S[i] in [#0..#32]) then
      Delete(S, i, 1);
  Result := S;
end;

function FirstDelimiter(S: String; Delimiter: Char): Integer;
var
  i: Integer;
begin
  Result := -1;
  i := 1;
  if S = '' then
    Exit;
  while S[i] <> Delimiter do
  begin
    if i > Length(S) then
      break;
    inc(i);
  end;
  Result := i;
end;

function LastDelimiter(S: String; Delimiter: Char): Integer;
var
  i: Integer;
begin
  Result := -1;
  i := Length(S);
  if (S = '') or (i = 0) then
    Exit;
  while S[i] <> Delimiter do
  begin
    if i < 0 then
      break;
    dec(i);
  end;
  Result := i;
end;

function ExtractFilePath(sFilename: String): String;
begin
  if LastDelimiter(sFilename, '\') = -1 then
    Exit;
  Result := Copy(sFilename, 1, LastDelimiter(sFilename, '\'));
end;

function ExtractFileName(sFilename: String): String;
begin
  if LastDelimiter(sFilename, '\') = -1 then
    Exit;
  Result := Copy(sFilename, LastDelimiter(sFilename, '\') +1, Length(sFilename));
end;

function ExtractFileExt(sFilename: String): String;
begin
  if LastDelimiter(sFilename, '.') = -1 then
    Exit;
  Result := Copy(sFilename, LastDelimiter(sFilename, '.'), Length(sFilename));
end;

function ExtractDriveName(sFilename: String): String;
begin
  if FirstDelimiter(sFilename, '\') = -1 then
    Exit;
  Result := Copy(sFilename, 1, FirstDelimiter(sFilename, '\'));
end;

function ExtractURLSite(S: String): String;
begin
  Result := Copy(S, 1, Pos('/', S) - 1);
end;

function ExtractURLPath(S: String): String;
begin
  Result := Copy(S, Pos('/', S), Length(S) - Pos('/', S) + 1);
end;

function ExtractMyFilename: String;
var
  lpBuffer: Array[0..MAX_PATH] of Char;
begin
  GetModuleFileName(GetModuleHandle(nil), lpBuffer, sizeof(lpBuffer));
  Result := String(lpBuffer);
end;

function ExtractMyFilePath: String;
begin
  Result := ExtractFilePath(ExtractMyFilename);
end;

function ReplaceChar(S: String; Old, New: Char): String;
var
  i, j: Integer;
begin
  for j := 0 to Length(S) do
  begin
    i := Pos(Old, S);
    if i > 0 then
      S[i] := New;
  end;
  Result := S;
end;

{
  Ripped from SysUtils
}
function ReplaceString(S, OldPattern, NewPattern: String): String;
var
  SearchStr, Patt, NewStr: string;
  Offset: Integer;
begin
  SearchStr := S;
  Patt := OldPattern;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := Pos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;

function GetLastErrorMsg: String;
  function MAKELANGID(usPrimaryLanguage, usSubLanguage: Byte): Word;
  begin
    Result := ((usSubLanguage shl 10) + usPrimaryLanguage);
  end;
var
  lpMsgBuffer: PChar;
begin
  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM, nil,
                GetLastError, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), @lpMsgBuffer, 0, nil);
  Result := Copy(lpMsgBuffer, 1, Length(lpMsgBuffer) -2);
end;

{
  by Luckie
}
function Format(sFormat: String; Args: Array of const): String;
var
  i: Integer;
  pArgs1, pArgs2: PDWORD;
  lpBuffer: PChar;
begin
  pArgs1 := nil;
  if Length(Args) > 0 then
    GetMem(pArgs1, Length(Args) * sizeof(Pointer));
  pArgs2 := pArgs1;
  for i := 0 to High(Args) do
  begin
    pArgs2^ := DWORD(PDWORD(@Args[i])^);
    inc(pArgs2);
  end;
  GetMem(lpBuffer, 1024);
  try
    SetString(Result, lpBuffer, wvsprintf(lpBuffer, PChar(sFormat), PChar(pArgs1)));
  except
    Result := '';
  end;
  if pArgs1 <> nil then
    FreeMem(pArgs1);
  if lpBuffer <> nil then
    FreeMem(lpBuffer);
end;

{
  by Aphex
}
function Split(Input: String; Deliminator: String; Index: integer): String;
var
  StringLoop, StringCount: Integer;
  Buffer: String;
begin
  Buffer := '';
  if Index < 1 then Exit;
  StringCount := 0;
  StringLoop := 1;
  while (StringLoop <= Length(Input)) do
  begin
    if (Copy(Input, StringLoop, Length(Deliminator)) = Deliminator) then
    begin
      Inc(StringLoop, Length(Deliminator) - 1);
      Inc(StringCount);
      if StringCount = Index then
      begin
        Result := Buffer;
        Exit;
      end else
        Buffer := '';
    end else
      Buffer := Buffer + Copy(Input, StringLoop, 1);
    Inc(StringLoop, 1);
  end;
  Inc(StringCount);
  if StringCount < Index then Buffer := '';
  Result := Buffer;
end;

function DownloadFileFromNet(sURL, sDestination: String): Boolean;
var
  hSocket, hFile: THandle;
  WSData: TWSAData;
  SockAddr: TSockAddr;
  HostEnt: PHostEnt;
  IPAddress, sGet, Location, Site, URL: String;
  i, intReceived, intPosition: Integer;
  lpNumberOfBytesWritten: DWORD;
  lpBuffer: Array[0..1024] of Char;
const
  szGet = 'GET %s HTTP/1.1' + lpEnter +
         'Host: %s' + lpEnter +
         'Connection: close' + lpEnter + lpEnter;
begin
  Result := False;

  Location := Split(sURL, '://', 2);
  Site := ExtractURLSite(Location);
  URL := ExtractURLPath(Location);

  if FileExists(sDestination) then
    DeleteFile(PChar(sDestination));
  hFile := CreateFile(PChar(sDestination), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_NEW, 0, 0);

  WSAStartup($0101, WSData);
  hSocket := Socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  HostEnt := GetHostByName(PAnsiChar(Site));
  if HostEnt <> nil then
  begin
    for i := 0 to HostEnt^.h_length -1 do
      IPAddress := IPAddress + IntToStr(Ord(HostEnt.h_addr_list^[i])) + '.';
    SetLength(IPAddress, Length(IPAddress) -1);
  end;

  SockAddr.sin_family := AF_INET;
  SockAddr.sin_port := htons(80);
  SockAddr.sin_addr.S_addr := inet_addr(PAnsiChar(IpAddress));

  if connect(hSocket, SockAddr, sizeof(SockAddr)) = SOCKET_ERROR then
    Exit;

  sGet := Format(szGet, [URL, Site]);
  ZeroMemory(@lpBuffer, sizeof(lpBuffer));
  if send(hSocket, sGet[1], Length(sGet), 0) = SOCKET_ERROR then
    Exit;

  repeat
    ZeroMemory(@lpBuffer, sizeof(lpBuffer));
    intReceived := recv(hSocket, lpBuffer, sizeof(lpBuffer), 0);
    if (Copy(lpBuffer, 0, 15) = 'HTTP/1.1 200 OK') or
       (Copy(lpBuffer, 0, 15) = 'HTTP/1.0 200 OK') then
    begin
      intPosition := Pos(lpEnter + lpEnter, lpBuffer) +3;
      WriteFile(hFile, lpBuffer[intPosition], intReceived - intPosition, lpNumberOfBytesWritten, nil);
      continue;
    end else
      WriteFile(hFile, lpBuffer, intReceived, lpNumberOfBytesWritten, nil);
  until (intReceived = SOCKET_ERROR) or (intReceived = 0);

  CloseSocket(hSocket);
  CloseHandle(hFile);
  Result := True;
end;

function GetFileDateTime(lpFilename: String): String;
var
  i, j: Integer;
  hFile: THandle;
  lpFindFileData: TWin32FindData;
  lpSystemTime: TSystemTime;
  lpDate: PChar;
  lpTime: PChar;
const
  sResult = '%s / %s';
begin
  Result := '';
  hFile := FindFirstFile(PChar(lpFilename), lpFindFileData);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    lpDate := nil;
    lpTime := nil;
    FileTimeToSystemTime(lpFindFileData.ftLastAccessTime, lpSystemTime);
    i := GetDateFormat(LOCALE_USER_DEFAULT, 0, @lpSystemTime, 'dd MMMM, yyyy', nil, 0);
    if i > 0 then
    begin
      GetMem(lpDate, i);
      GetDateFormat(LOCALE_USER_DEFAULT, 0, @lpSystemTime, 'dd MMMM, yyyy', lpDate, i);
    end;
    j := GetTimeFormat(LOCALE_USER_DEFAULT, 0, @lpSystemTime, 'HH:mm', nil, 0);
    if j > 0 then
    begin
      GetMem(lpTime, j);
      GetTimeFormat(LOCALE_USER_DEFAULT, 0, @lpSystemTime, 'HH:mm', lpTime, j);
    end;
    Result := Format(sResult, [lpDate, lpTime]);
    FreeMem(lpDate, i);
    FreeMem(lpTime, j);
  end;
  FindClose(hFile);
end;

function FormatBytes(Number: Integer): String; overload;
var
  i: Integer;
  Negative: Boolean;
begin
  Negative := Number < 0;
  Number := Abs(Number);
  Result := IntToStr(Number);
  i := Length(Result) -2;
  while i > 1 do
  begin
    Insert('.', Result, i);
    Dec(i, 3);
  end;
  if Negative then
    Result := '-' + Result;
end;

function FormatBytes(sNumber: String): String; overload;
var
  i, iComma: Integer;
begin
  iComma := Pos(',', sNumber) -1;
  iComma := Length(sNumber) - iComma;
  i := Length(sNumber) -2 - iComma;
  while i > 1 do
  begin
    Insert('.', sNumber, i);
    Dec(i, 3);
  end;
  Result := sNumber;
end;

{
  Based on Aphex's code. :)
}
function TranslateSize(Size: TLargeInteger): String;
const
  Formats: Array[0..3] of String =  (' Bytes', ' KB', ' MB', ' GB');
var
  i: Integer;
  Tmp: Real;
  TmpResult: String;
begin
  i := -1;
  Tmp := Size;
  while (i <= 3) do
  begin
    Tmp := Tmp / 1024;
    Inc(i);
    if trunc(Tmp) = 0 then
    begin
      Tmp := Tmp * 1024;
      Break;
    end;
  end;
  TmpResult := FloatToStr(Tmp);
  TmpResult := FormatBytes(TmpResult);
  if Copy(TmpResult, Length(TmpResult) -2, 3) = ',00' then
    TmpResult := Copy(TmpResult, 1, Length(TmpResult) -3);
  Result := TmpResult + Formats[i];
end;

function GetFileSize(FileName: String): DWORD;
var
  hFile: THandle;
begin
  Result := INVALID_HANDLE_VALUE; // DWORD(-1)
  hFile := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
    Result := Windows.GetFileSize(hFile, nil);
  CloseHandle(hFile);
end;

function GetFileSizeFormated(FileName: String): String;
var
  hFile: THandle;
  dwSize: DWORD;
begin
  Result := '';
  dwSize := 0;
  hFile := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
    dwSize := Windows.GetFileSize(hFile, nil);
  CloseHandle(hFile);
  Result := TranslateSize(dwSize);
end;

function FileExists(FileName: String): Boolean;
var
  hFile: THandle;
  lpFindFileData: TWin32FindData;
begin
  Result := False;
  hFile := FindFirstFile(PChar(FileName), lpFindFileData);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    FindClose(hFile);
    Result := True;
  end;
end;

function DirectoryExists(DirectoryName: String): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(DirectoryName));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

function DeleteFolder(Path: String): Boolean;
var
  hFile: THandle;
  lpFindFileData: TWin32FindData;
  sFilename: String;
  Directory: Boolean;
begin
  Result := False;
  if Path[Length(Path)] <> '\' then
    Path := Path + '\';
  hFile := FindFirstFile(PChar(Path + '*.*'), lpFindFileData);
  if hFile = INVALID_HANDLE_VALUE then
    Exit;
  repeat
    sFilename := lpFindFileData.cFileName;
    if ((sFilename <> '.') and (sFilename <> '..')) then
    begin
      Directory := (lpFindFileData.dwFileAttributes <> INVALID_HANDLE_VALUE) and
                   (FILE_ATTRIBUTE_DIRECTORY and lpFindFileData.dwFileAttributes <> 0);
      if Directory = False then
      begin
        sFilename := Path + sFilename;
        DeleteFile(PChar(sFilename));
      end else
      begin
        DeleteFolder(Path + sFilename + '\');
      end;
    end;
  until FindNextFile(hFile, lpFindFileData) = False;
  FindClose(hFile);
  if RemoveDirectory(PChar(Path)) then
    Result := True;
end;

function GetWindowsVersion: String;
var
  lpVersionInformation: TOSVersionInfo;
begin
  lpVersionInformation.dwOSVersionInfoSize := sizeof(TOsVersionInfo);
  GetVersionEx(lpVersionInformation);
  with lpVersionInformation do
  begin
    case dwPlatformId of
      VER_PLATFORM_WIN32s: Result := 'Microsoft Win32s';
      VER_PLATFORM_WIN32_WINDOWS:
      begin
        if (dwMajorVersion = 4) and (dwMinorVersion = 0) then
          Result := 'Microsoft Windows 95'
        else if (dwMajorVersion = 4) and (dwMinorVersion = 10) then
          Result := 'Microsoft Windows 98'
        else if (dwMajorVersion = 4) and (dwMinorVersion = 90) then
          Result := 'Microsoft Windows Millennium Edition (ME)';
      end;
      VER_PLATFORM_WIN32_NT:
      begin
        if (dwMajorVersion = 5) and (dwMinorVersion = 2) then
          Result := 'Microsoft Windows Server 2003'
        else if (dwMajorVersion = 5) and (dwMinorVersion = 1) then
          Result := 'Microsoft Windows XP'
        else if (dwMajorVersion = 5) and (dwMinorVersion = 0) then
          Result := 'Microsoft Windows 2000'
        else
          Result := 'Microsoft Windows NT'
      end;
    end;
  end;
end;

function IsWindows9x: Boolean;
var
  lpVersionInformation: TOSVersionInfo;
begin
  lpVersionInformation.dwOSVersionInfoSize := sizeof(TOsVersionInfo);
  GetVersionEx(lpVersionInformation);
  Result := lpVersionInformation.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS;
end;

function IsWindowsNt: Boolean;
var
  lpVersionInformation: TOSVersionInfo;
begin
  lpVersionInformation.dwOSVersionInfoSize := sizeof(TOsVersionInfo);
  GetVersionEx(lpVersionInformation);
  Result := lpVersionInformation.dwPlatformId = VER_PLATFORM_WIN32_NT;
end;

function GetWindowsDirectory: String;
var
  lpBuffer: Array[0..MAX_PATH] of Char;
begin
  GetWindowsDirectoryA(@lpBuffer, sizeof(lpBuffer));
  Result := String(lpBuffer) + '\';
end;

function GetSystemDirectory: String;
var
  lpBuffer: Array[0..MAX_PATH] of Char;
begin
  GetSystemDirectoryA(@lpBuffer, sizeof(lpBuffer));
  Result := String(lpBuffer) + '\';
end;

function GetTempDirectory: String;
var
  lpBuffer: Array[0..MAX_PATH] of Char;
begin
  Windows.GetTempPath(sizeof(lpBuffer), lpBuffer);
  Result := String(lpBuffer);
end;

function GetUsername: String;
var
  lpBuffer: Array[0..MAX_COMPUTERNAME_LENGTH +1] of Char;
  nSize: Cardinal;
begin
  nSize := sizeof(lpBuffer);
  GetUserNameA(@lpBuffer, nSize);
  Result := String(lpBuffer);
end;

function GetComputername: String;
var
  lpBuffer: Array[0..MAX_COMPUTERNAME_LENGTH +1] of Char;
  nSize: Cardinal;
begin
  ZeroMemory(@lpBuffer, sizeof(lpBuffer));
  nSize := sizeof(lpBuffer);
  GetComputerNameA(@lpBuffer, nSize);
  Result := String(lpBuffer);
end;

function FormatTime(MilliSec: DWORD): String;
const
  sResult1 = '%dd %dh %dm %dsec';
  sResult2 = '%dh %dm %dsec';
  sResult3 = '%dm %dsec';
  sResult4 = '%dsec';
  Day: DWORD = 1000 * 60 * 60 * 24;
  Hour: Integer = 1000 * 60 * 60;
  Minute: Integer = 1000 * 60;
  Seconds: Integer = 1000;
var
  intTmp, intDay, intHours, intMinutes, intSeconds: Integer;
begin
  intDay := MilliSec div Day;
  intTmp := MilliSec mod Day;
  intHours := intTmp div Hour;
  intTmp := intTmp mod Hour;
  intMinutes := intTmp div Minute;
  intTmp := intTmp mod Minute;
  intSeconds := intTmp div Seconds;
  if (intDay = 0) and (intHours = 0) and (intMinutes = 0) then
    Result := Format(sResult4, [intSeconds])
  else if (intDay = 0) and (intHours = 0) then
    Result := Format(sResult3, [intMinutes, intSeconds])
  else if (intDay = 0) then
    Result := Format(sResult2, [intHours, intMinutes, intSeconds])
  else
    Result := Format(sResult1, [intDay, intHours, intMinutes, intSeconds]);
end;

function GetWindowsUpTime: String;
begin
  Result := FormatTime(GetTickCount);
end;

{
BlockKeys:
  CompanyName
  FileDescription
  FileVersion
  InternalName
  LegalCopyright
  OriginalFilename
  ProductName
  ProductVersion
}
function GetFileVersionInfo(Filename, BlockKey: String): String;
var
  vSize, Dummy: DWORD;
  vData, Translation, Ip: Pointer;
begin
  Result := '';
  vSize := GetFileVersionInfoSize(PChar(Filename), Dummy);
  if (vSize >0) then
  begin
    GetMem(vData, vSize);
    try
      GetFileVersionInfoA(PAnsiChar(Filename), 0, vSize, vData);
      if vData = nil then Exit;
      VerQueryValue(vData, '\\VarFileInfo\\Translation', Translation, vSize);
      if Translation = nil then Exit;
      VerQueryValue(vData, PChar(Format('\\StringFileInfo\\%.4x%.4x\\%s', [LOWORD(LongInt(Translation^)), HIWORD(LongInt(Translation^)), BlockKey])), Ip, vSize);
      if Ip = nil then Exit;
      SetString(Result, PChar(Ip), vSize -1);
    finally
      FreeMem(vData);
    end;
  end;
end;

function SetDebugPrivilege: Boolean;
var
  hToken: THandle;
  TP: TTokenPrivileges;
  lpLuid: TLargeInteger;
  dwReturnLength: DWORD;
begin
  Result := False;
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  begin
    if LookupPrivilegeValue(nil, 'SeDebugPrivilege', lpLuid) then
    begin
      TP.PrivilegeCount := 1;
      TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      TP.Privileges[0].Luid := lpLuid;
      Result := AdjustTokenPrivileges(hToken, False, TP, sizeof(TP), nil, dwReturnLength);
    end;
    CloseHandle(hToken);
  end;
end;

function GetEnvironmentValue(Value: String): String;
var
  Size: Integer;
begin
  Size := GetEnvironmentVariable(PChar(Value), nil, 0);
  if Size > 0 then
  begin
    SetLength(Result, Size -1);
    GetEnvironmentVariable(PChar(Value), PChar(Result), Size);
  end else
    Result := '';
end;

function GetDefaultBrowser: String;
var
  phkResult: HKEY;
  lpData: Pointer;
  lpcbData, lpType: DWORD;
begin
  lpType := REG_SZ;
  if RegOpenKeyEx(HKEY_CLASSES_ROOT, 'http\shell\open\command\', 0, KEY_READ, phkResult) = ERROR_SUCCESS then
  begin
    if RegQueryValueEx(phkResult, nil, nil, @lpType, nil, @lpcbData) = ERROR_SUCCESS then
    begin
      GetMem(lpData, lpcbData);
      if RegQueryValueEx(phkResult, nil, nil, @lpType, lpData, @lpcbData) = ERROR_SUCCESS then
      begin
        Dec(lpcbData);
        SetLength(Result, lpcbData);
        CopyMemory(@Result[1], lpData, lpcbData);
        Result := Result;
      end;
      FreeMem(lpData, lpcbData);
    end;
  end;
  if Result = '' then
    Exit;
  Result := LowerString(Result);
  if Result[1] = '"' then
    Result := Copy(Result, 2, Pos('.exe', Result) +2)
  else
    Result := Copy(Result, 1, Pos('.exe', Result) +3);
end;

function ExtractResource(lpFilename: String; lpName, lpType: PChar): Boolean;
var
  hResInfo, hResData: HRSRC;
  dwResSize, lpNumberOfBytesWritten: DWORD;
  hFile: THandle;
  lpBuffer: Pointer;
begin
  Result := False;
  hResInfo := FindResource(hInstance, lpName, lpType);
  if hResInfo <> 0 then
  begin
    dwResSize := SizeOfResource(hInstance, hResInfo);
    if dwResSize <> 0 then
    begin
      hResData := LoadResource(hInstance, hResInfo);
      if hResData <> 0 then
      begin
        lpBuffer := LockResource(hResData);
        if lpBuffer <> nil then
        begin
          hFile := CreateFile(PChar(lpFilename), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
          if hFile <> INVALID_HANDLE_VALUE then
          begin
            WriteFile(hFile, lpBuffer^, dwResSize, lpNumberOfBytesWritten, nil);
            CloseHandle(hFile);
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

function GetResourceData(lpName, lpType: PChar; var dwResSize: DWORD): Pointer;
var
  hResInfo, hResData: HRSRC;
  // OldProtect: Cardinal;
  lpBuffer: Pointer;
begin
  Result := nil;
  hResInfo := FindResource(hInstance, lpName, lpType);
  if hResInfo <> 0 then
  begin
    dwResSize := SizeOfResource(hInstance, hResInfo);
    if dwResSize <> 0 then
    begin
      hResData := LoadResource(hInstance, hResInfo);
      if hResData <> 0 then
      begin
        lpBuffer := LockResource(hResData);
        if lpBuffer <> nil then
        begin
          // VirtualProtect(lpBuffer, dwResSize, PAGE_EXECUTE_READWRITE, OldProtect);
          Result := lpBuffer;
          UnlockResource(hResData);
        end;
      end;
    end;
  end;
end;

function GetFileData(lpFilename: String; var dwFileSize: DWORD): Pointer;
var
  hFile: THandle;
  lpNumberOfBytesRead: DWORD;
begin
  Result := nil;
  hFile := CreateFile(PChar(lpFilename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    dwFileSize := Windows.GetFileSize(hFile, nil);
    GetMem(Result, dwFileSize);
    ReadFile(hFile, Result^, dwFileSize, lpNumberOfBytesRead, nil);
    CloseHandle(hFile);
  end;
end;

function SaveToFile(lpFilename: String; lpBuffer: Pointer; Size: DWORD = INVALID_HANDLE_VALUE): Boolean;
var
  hFile: THandle;
  lpNumberOfBytesWritten: DWORD;
begin
  Result := False;
  hFile := CreateFile(PChar(lpFilename), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    if Size = INVALID_HANDLE_VALUE then
      Size := GetPointerSize(lpBuffer);
    WriteFile(hFile, lpBuffer^, Size, lpNumberOfBytesWritten, nil);
    CloseHandle(hFile);
    Result := True;
  end;
end;

function GetEOFData(lpFilename: String; var lpBuffer: Pointer; var dwLength: Cardinal): Boolean;
var
  hFile, hFileMappingObject: THandle;
  lpBaseAddress: Pointer;
  NtHeaders: PImageNtHeaders;
  SectionHeader: PImageSectionHeader;
  dwFileSize, dwTemp, dwBestSize: DWORD;
  i: Integer;
begin
  Result := False;
  dwLength := 0;
  if lpBuffer <> nil then
  begin
    ShowMessage('Buffer must be nil!', 'Utils', MB_ICONERROR);
    Exit;
  end;
  hFile := CreateFile(PChar(lpFilename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    dwFileSize := Windows.GetFileSize(hFile, nil);
    hFileMappingObject := CreateFileMapping(hFile, nil, PAGE_READONLY, 0, 0, nil);
    if ((hFileMappingObject <> INVALID_HANDLE_VALUE) or (hFileMappingObject <> 0)) then
    begin
      lpBaseAddress := MapViewOfFile(hFileMappingObject, FILE_MAP_READ, 0, 0, 0);
      if lpBaseAddress <> nil then
      begin
        NtHeaders := PImageNtHeaders(DWORD(lpBaseAddress) + DWORD(PImageDosHeader(lpBaseAddress)._lfanew));
        if NtHeaders.Signature = IMAGE_NT_SIGNATURE then
        begin
          dwBestSize := 0;
          for i := 0 to NtHeaders^.FileHeader.NumberOfSections -1 do
          begin
            SectionHeader := PImageSectionHeader(DWORD(NtHeaders) + sizeof(TImageNtHeaders) + DWORD(sizeof(TImageSectionHeader) * i));
            dwTemp := SectionHeader^.PointerToRawData + SectionHeader^.SizeOfRawData;
            if dwTemp > dwBestSize then
              dwBestSize := dwTemp;
          end;
          if dwBestSize <> 0 then
          begin
            dwLength := dwFileSize - dwBestSize;
            lpBuffer := VirtualAlloc(nil, dwLength, MEM_COMMIT, PAGE_READWRITE);
            CopyMemory(lpBuffer, Pointer(DWORD(lpBaseAddress) + dwBestSize), dwLength);
            UnmapViewOfFile(lpBaseAddress);
            CloseHandle(hFileMappingObject);
            CloseHandle(hFile);
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

{
  Example: OpenFile(0, 'Exe-Files|*.exe' + #0 + 'All Files|*.*', 'Select your File', sFilename);
}
function OpenFile(hParent: THandle; Filter, Title: String; var lpFilename: String): Boolean;
var
  Ofn: TOpenFileName;
  szFilename: Array[0..MAX_PATH] of Char;
begin
  Result := False;
  ZeroMemory(@Ofn, sizeof(TOpenFileName));
  ZeroMemory(@szFilename, sizeof(szFilename));
  with Ofn do
  begin
    lStructSize := SizeOf(TOpenFileName);
    hwndOwner := hParent;
    hInstance := hInstance;
    lpstrFile := @szFilename;
    nMaxFile := sizeof(szFilename);
    lpstrTitle := PAnsiChar(Title);
    Flags := OFN_HIDEREADONLY or OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST;
    lpstrFilter := PAnsiChar(ReplaceChar(Filter, '|', #0) + #0#0);
  end;
  if GetOpenFileName(Ofn) then
  begin
    Result := True;
    lpFileName := String(szFileName);
  end;
end;

function SaveFile(hParent: THandle; Filter, Title: String; var lpFilename: String): Boolean;
var
  Ofn: TOpenFileName;
  szFilename: Array[0..MAX_PATH] of Char;
begin
  Result := False;
  ZeroMemory(@Ofn, sizeof(TOpenFileName));
  ZeroMemory(@szFilename, sizeof(szFilename));
  with Ofn do
  begin
    lStructSize := SizeOf(TOpenFileName);
    hwndOwner := hParent;
    hInstance := hInstance;
    lpstrFile := @szFilename;
    nMaxFile := sizeof(szFilename);
    lpstrTitle := PAnsiChar(Title);
    Flags := OFN_HIDEREADONLY or OFN_PATHMUSTEXIST;
    lpstrFilter := PAnsiChar(ReplaceChar(Filter, '|', #0) + #0#0);
  end;
  if GetSaveFileName(Ofn) then
  begin
    Result := True;
    lpFileName := String(szFileName);
  end;
end;

procedure ProcessMessages;
var
  Msg: TMsg;
begin
  if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
  begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;

procedure XorEncrypt(lpBuffer: Pointer; Count, Key: DWORD);
var
  i: DWORD;
begin
  for i := 0 to Count -1 do
  begin
    PDWORD(DWORD(lpBuffer) +i)^ := DWORD(Ord(PDWORD(DWORD(lpBuffer) +i)^ xor Key));
  end;
end;

function XorEncryptStr(sBuffer: String; Key: DWORD): String;
begin
  XorEncrypt(@sBuffer[1], Length(sBuffer), Key);
  Result := sBuffer;
end;

function GetPointerSize(lpBuffer: Pointer): Cardinal;
begin
  if lpBuffer = nil then
    Result := Cardinal(-1)
  else
    Result := Cardinal(Pointer(Cardinal(lpBuffer) -4)^) and $7FFFFFFC -4;
end;

function MyGetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC;
var
  DataDirectory: TImageDataDirectory;
  lpExports, lpExport: PImageExportDirectory;
  i: Cardinal;
  Ordinal: Word;
  dwRVA: ^Cardinal;
begin
  Result := nil;
  DataDirectory := PImageNtHeaders(Cardinal(hModule) + Cardinal(PImageDosHeader(hModule)^._lfanew))^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT];
  lpExports := Pointer(hModule + DataDirectory.VirtualAddress);
  for i := 0 to lpExports.NumberOfNames -1 do
  begin
    lpExport := PImageExportDirectory(hModule + DWORD(lpExports.AddressOfNames) + i * sizeof(DWORD));
    if lstrcmp(PWideChar(lpProcName), PWideChar(hModule + lpExport.Name)) = 0 then
    begin
      Ordinal := PWord(hModule + DWORD(lpExports.AddressOfNameOrdinals) + i * sizeof(Word))^;
      Inc(Ordinal, 3);
      dwRva := Pointer(hModule + DWORD(lpExports.AddressOfFunctions) + Ordinal * sizeof(DWORD));
      Result := Pointer(hModule + dwRVA^);
      Break;
    end;
  end;
end;

function MyLoadLibrary(lpLibFileName: PAnsiChar): HMODULE;
var
  xLoadLibrary: function(lpLibFileName: PAnsiChar): HMODULE; stdcall;
begin
  xLoadLibrary := MyGetProcAddress(GetModuleHandle(kernel32), 'LoadLibraryA');
  Result := xLoadLibrary(lpLibFilename);
end;

end.

