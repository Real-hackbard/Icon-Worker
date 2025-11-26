unit untIcons;

interface

uses
  Windows, untUtils;

type
  PByte = ^Byte;
  PBitmapInfo = ^BitmapInfo;

/// These first two structs represent how the icon information is stored
/// when it is bound into a EXE or DLL file. Structure members are WORD
/// aligned and the last member of the structure is the ID instead of
/// the imageoffset.

type
  PMEMICONDIRENTRY = ^TMEMICONDIRENTRY;
  TMEMICONDIRENTRY = packed record
    bWidth:           Byte;
    bHeight:          Byte;
    bColorCount:      Byte;
    bReserved:        Byte;
    wPlanes:          Word;
    wBitCount:        Word;
    dwBytesInRes:     DWORD;
    nID:              Word;
  end;

type
  PMEMICONDIR = ^TMEMICONDIR;
  TMEMICONDIR = packed record
    idReserved:       Word;
    idType:           Word;
    idCount:          Word;
    idEntries:        Array[0..15] of TMEMICONDIRENTRY;
  end;

/// These next two structs represent how the icon information is stored
/// in an ICO file.

type
  PICONDIRENTRY = ^TICONDIRENTRY;
  TICONDIRENTRY = packed record
    bWidth:           Byte;
    bHeight:          Byte;
    bColorCount:      Byte;
    bReserved:        Byte;
    wPlanes:          Word;
    wBitCount:        Word;
    dwBytesInRes:     DWORD;
    dwImageOffset:    DWORD;
  end;

type
  PICONDIR = ^TICONDIR;
  TICONDIR = packed record
    idReserved:       Word;
    idType:           Word;
    idCount:          Word;
    idEntries:        Array[0..0] of TICONDIRENTRY;
  end;

/// The following two structs are for the use of this program in
/// manipulating icons. They are more closely tied to the operation
/// of this program than the structures listed above. One of the
/// main differences is that they provide a pointer to the DIB
/// information of the masks.

type
  PICONIMAGE = ^TICONIMAGE;
  TICONIMAGE = packed record
    Width,
    Height,
    Colors:           UINT;
    lpBits:           Pointer;
    dwNumBytes:       DWORD;
    pBmpInfo:         PBitmapInfo;
  end;

type
  PICONRESOURCE = ^TICONRESOURCE;
  TICONRESOURCE = packed record
    nNumImages:       UINT;
    IconImages:       Array[0..15] of TICONIMAGE;
  end;

type
  TPageInfo = packed record
    Width:            Byte;
    Height:           Byte;
    ColorQuantity:    Integer;
    Reserved:         DWORD;
    PageSize:         DWORD;
    PageOffSet:       DWORD;
  end;

type
  TPageDataHeader = packed record
    PageHeadSize:     DWORD;
    XSize:            DWORD;
    YSize:            DWORD;
    SpeDataPerPixSize: Integer;
    ColorDataPerPixSize: Integer;
    Reserved:         DWORD;
    DataAreaSize:     DWORD;
    ReservedArray:    Array[0..15] of char;
  end;

type
  TIcoFileHeader = packed record
    FileFlag:         Array[0..3] of byte;
    PageQuartity:     Integer;
    PageInfo:         TPageInfo;
  end;

function ExtractIconFromFile(ResFileName: string; IcoFileName: string; nIndex: string): Boolean;
function WriteIconResourceToFile(hFile: hwnd; lpIR: PICONRESOURCE): Boolean;

implementation

function WriteICOHeader(hFile: THandle; nNumEntries: UINT): Boolean;
type
  TFIcoHeader = record
    wReserved: WORD;
    wType: WORD;
    wNumEntries: WORD;
  end;
var
  IcoHeader: TFIcoHeader;
  dwBytesWritten: DWORD;
begin
  Result := False;
  IcoHeader.wReserved := 0;
  IcoHeader.wType := 1;
  IcoHeader.wNumEntries := WORD(nNumEntries);
  if not WriteFile(hFile, IcoHeader, SizeOf(IcoHeader), dwBytesWritten, nil) then
  begin
    MessageBox(0, PChar(GetLastErrorMsg), 'Error', MB_ICONERROR);
    Result := False;
    Exit;
  end;
  if dwBytesWritten <> SizeOf(IcoHeader) then
    Exit;
  Result := True;
end;

function CalculateImageOffset(lpIR: PICONRESOURCE; nIndex: UINT): DWORD;
var
  dwSize: DWORD;
  i: Integer;
begin
{$R-}
{$Q-}
  dwSize := 3 * SizeOf(WORD);
  inc(dwSize, lpIR.nNumImages * SizeOf(TICONDIRENTRY));
  for i := 0 to nIndex - 1 do
    inc(dwSize, lpIR.IconImages[i].dwNumBytes);
  Result := dwSize;
{$R+}
{$Q+}
end;

function WriteIconResourceToFile(hFile: hwnd; lpIR: PICONRESOURCE): Boolean;
var
  i: UINT;
  dwBytesWritten: DWORD;
  ide: TICONDIRENTRY;
  dwTemp: DWORD;
begin
{$R-}
  Result := False;
  for i := 0 to lpIR^.nNumImages - 1 do
  begin
    /// Convert internal format to ICONDIRENTRY
    ide.bWidth := lpIR^.IconImages[i].Width;
    ide.bHeight := lpIR^.IconImages[i].Height;
    ide.bReserved := 0;
    ide.wPlanes := lpIR^.IconImages[i].pBmpInfo.bmiHeader.biPlanes;
    ide.wBitCount := lpIR^.IconImages[i].pBmpInfo.bmiHeader.biBitCount;
    if ide.wPlanes * ide.wBitCount >= 8 then
      ide.bColorCount := 0
    else
      ide.bColorCount := 1 shl (ide.wPlanes * ide.wBitCount);
    ide.dwBytesInRes := lpIR^.IconImages[i].dwNumBytes;
    ide.dwImageOffset := CalculateImageOffset(lpIR, i);
    // Write the ICONDIRENTRY out to disk
    if not WriteFile(hFile, ide, sizeof(TICONDIRENTRY), dwBytesWritten, nil) then
      Exit;
    // Did we write a full ICONDIRENTRY ?
    if dwBytesWritten <> sizeof(TICONDIRENTRY) then
      Exit;
  end;
    /// Write the image bits for each image
  for i := 0 to lpIR^.nNumImages - 1 do
  begin
    dwTemp := lpIR^.IconImages[i].pBmpInfo^.bmiHeader.biSizeImage;
    // Set the sizeimage member to zero
    lpIR^.IconImages[i].pBmpInfo^.bmiHeader.biSizeImage := 0;
    // Write the image bits to file
    if not WriteFile(hFile, lpIR^.IconImages[i].lpBits^, lpIR^.IconImages[i].dwNumBytes, dwBytesWritten, nil) then
      Exit;
    if dwBytesWritten <> lpIR^.IconImages[i].dwNumBytes then
      Exit;
    // set it back
    lpIR^.IconImages[i].pBmpInfo^.bmiHeader.biSizeImage := dwTemp;
  end;
  Result := True;
{$R+}
end;

function AWriteIconToFile(bitmap: hBitmap; Icon: hIcon; szFileName: string): Boolean;
var
  fh: file of byte;
  IconInfo: _ICONINFO;
  PageInfo: TPageInfo;
  PageDataHeader: TPageDataHeader;
  IcoFileHeader: TIcoFileHeader;
  BitsInfo: tagBITMAPINFO;
  p: pointer;
  PageDataSize: integer;
begin
  Result := False;
  GetIconInfo(Icon, IconInfo);
  AssignFile(fh, szFileName);
  FileMode := 1;
  Reset(fh);

  GetDIBits(0, Icon, 0, 32, nil, BitsInfo, DIB_PAL_COLORS);
  GetDIBits(0, Icon, 0, 32, p, BitsInfo, DIB_PAL_COLORS);
  PageDataSize := SizeOf(PageDataHeader) + BitsInfo.bmiHeader.biBitCount;

  PageInfo.Width := 32;
  PageInfo.Height := 32;
  PageInfo.ColorQuantity := 65535;
  Pageinfo.Reserved := 0;
  PageInfo.PageSize := PageDataSize;
  PageInfo.PageOffSet := SizeOf(IcoFileHeader);

  IcoFileHeader.FileFlag[0] := 0;
  IcoFileHeader.FileFlag[1] := 0;
  IcoFileHeader.FileFlag[2] := 1;
  IcoFileHeader.FileFlag[3] := 0;
  IcoFileHeader.PageQuartity := 1;
  IcoFileHeader.PageInfo := PageInfo;

  FillChar(PageDataHeader, SizeOf(PageDataHeader), 0);
  PageDataHeader.XSize := 32;
  PageDataHeader.YSize := 32;
  PageDataHeader.SpeDataPerPixSize := 0;
  PageDataHeader.ColorDataPerPixSize := 32;
  PageDataHeader.PageHeadSize := SizeOf(PageDataHeader);
  PageDataHeader.Reserved := 0;
  PageDataHeader.DataAreaSize := BitsInfo.bmiHeader.biBitCount;

  BlockWrite(fh, IcoFileHeader, SizeOf(IcoFileHeader));
  BlockWrite(fh, PageDataHeader, SizeOf(PageDataHeader));
  BlockWrite(fh, p, BitsInfo.bmiHeader.biBitCount);
  CloseFile(fh);
end;

function AdjustIconImagePointers(lpImage: PICONIMAGE): Bool;
begin
  if lpImage = nil then
  begin
    Result := False;
    exit;
  end;
  lpImage.pBmpInfo := PBitMapInfo(lpImage^.lpBits);
  lpImage.Width := lpImage^.pBmpInfo^.bmiHeader.biWidth;
  lpImage.Height := (lpImage^.pBmpInfo^.bmiHeader.biHeight) div 2;
  lpImage.Colors := lpImage^.pBmpInfo^.bmiHeader.biPlanes * lpImage^.pBmpInfo^.bmiHeader.biBitCount;
  Result := true;
end;

function ExtractIconFromFile(ResFileName: string; IcoFileName: string; nIndex: string): Boolean;
var
  h: HMODULE;
  lpMemIcon: PMEMICONDIR;
  lpIR: TICONRESOURCE;
  src: HRSRC;
  Global: HGLOBAL;
  i: integer;       
  hFile: hwnd;
begin
  Result := False;
  hFile := CreateFile(pchar(IcoFileName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile = INVALID_HANDLE_VALUE then Exit;
  h := LoadLibraryEx(pchar(ResFileName), 0, LOAD_LIBRARY_AS_DATAFILE);
  if h = 0 then exit;
  try
    src := FindResource(h, pchar(nIndex), RT_GROUP_ICON);
    if src = 0 then
      Src := FindResource(h, Pointer(StrToInt(nIndex)), RT_GROUP_ICON);
    if src <> 0 then
    begin
      Global := LoadResource(h, src);
      if Global <> 0 then
      begin
        lpMemIcon := LockResource(Global);
        if Global <> 0 then
        begin
          try
            lpIR.nNumImages := lpMemIcon.idCount;
            // Write the header
            for i := 0 to lpMemIcon^.idCount - 1 do
            begin
              src := FindResource(h, MakeIntResource(lpMemIcon^.idEntries[i].nID), RT_ICON);
              if src <> 0 then
              begin
                Global := LoadResource(h, src);
                if Global <> 0 then
                begin
                  try
                    lpIR.IconImages[i].dwNumBytes := SizeofResource(h, src);
                  except
                    MessageBox(0, 'Error while reading Icon', 'Error', MB_ICONERROR);
                    Result := False;
                    FreeLibrary(h);
                    CloseHandle(hFile);
                    Exit;
                  end;
                  GetMem(lpIR.IconImages[i].lpBits, lpIR.IconImages[i].dwNumBytes);
                  CopyMemory(lpIR.IconImages[i].lpBits, LockResource(Global), lpIR.IconImages[i].dwNumBytes);
                  if not AdjustIconImagePointers(@(lpIR.IconImages[i])) then exit;
                end;
              end;
            end;
            if WriteICOHeader(hFile, lpIR.nNumImages) then
              if WriteIconResourceToFile(hFile, @lpIR) then
                Result := True;
          finally
            if Result = True then
              for i := 0 to lpIR.nNumImages - 1 do
                if assigned(lpIR.IconImages[i].lpBits) then
                  FreeMem(lpIR.IconImages[i].lpBits);
          end;
        end;
      end;
    end;
  finally
    FreeLibrary(h);
  end;
  CloseHandle(hFile);
end;

end.

