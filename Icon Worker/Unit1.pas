unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Types, Vcl.StdCtrls, Vcl.ExtCtrls, ShellApi, Vcl.ComCtrls,
  UntIcons, Vcl.Menus, System.ImageList, Vcl.ImgList;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Panel1: TPanel;
    Image1: TImage;
    CheckBox1: TCheckBox;
    Panel2: TPanel;
    Label3: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Button5: TButton;
    Edit2: TEdit;
    Button4: TButton;
    Button3: TButton;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Panel3: TPanel;
    Edit3: TEdit;
    Button2: TButton;
    ListView1: TListView;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    Refresh1: TMenuItem;
    ExtractIcon1: TMenuItem;
    N1: TMenuItem;
    Selectall1: TMenuItem;
    SaveDialog2: TSaveDialog;
    OpenDialog3: TOpenDialog;
    Image2: TImage;
    Panel4: TPanel;
    Image3: TImage;
    Button6: TButton;
    Button7: TButton;
    CheckBox2: TCheckBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Clear1: TMenuItem;
    Button8: TButton;
    Edit4: TEdit;
    Button9: TButton;
    Label15: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure ExtractIcon1Click(Sender: TObject);
    procedure Selectall1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    procedure LoadIcons(sFilename: String);
  end;

const
  ICON_HEADER_RESERVED = 0;
  ICON_HEADER_TYPE_ICO = 1;
  ICON_HEADER_TYPE_CUR = 2;

type
  PGroupIconRsrcEntry = ^TGroupIconRsrcEntry;
  TGroupIconRsrcEntry = packed record
    bWidth, bHeight: Byte; // 0 means 256, which is the maximum
    bColorCount: Byte;     // number of colors in image (0 if wBitCount > 8)
    bReserved: Byte;       // 0
    wPlanes: Word;         // 1
    wBitCount: Word;       // number of bits per pixel
    dwSize: DWORD;         // size of the icon data, in bytes
    wID: Word;             // resource ID of the icon (for RT_ICON entry)
  end;

  PGroupIconRsrcHeader = ^TGroupIconRsrcHeader;
  TGroupIconRsrcHeader = packed record
    wReserved: Word;       // 0
    wType: Word;           // 1 for icons
    wCount: Word;          // number of icons in this group, each has a following TGroupIconRsrcEntry
    // Entries: array [0..idType - 1] of TGroupIconRsrcEntry;
  end;


  TSmoGroupIcon = record
    Header: TGroupIconRsrcHeader;
    Entries: array of TGroupIconRsrcEntry;
    IconData: array of array of Byte;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
function Get_File_Size4(const S: string): Int64;
var
  FD: TWin32FindData;
  FH: THandle;
begin
  FH := FindFirstFile(PChar(S), FD);
  if FH = INVALID_HANDLE_VALUE then Result := 0
  else
    try
      Result := FD.nFileSizeHigh;
      Result := Result shl 32;
      Result := Result + FD.nFileSizeLow;
    finally
      //CloseHandle(FH);
    end;
end;

Function PickIconDlgW(OwnerWnd: HWND; lpstrFile: PWideChar; var nMaxFile: LongInt;
          var lpdwIconIndex: LongInt): LongBool; stdcall; external 'SHELL32.DLL' index 62;
{ [WriteIcon] }
  procedure WriteIcon(Stream: TStream; Icon: HICON; WriteLength: Boolean = False);

  const
    RC3_STOCKICON = 0;
    RC3_ICON      = 1;
    RC3_CURSOR    = 2;

  type
    PCursorOrIcon = ^TCursorOrIcon;
    TCursorOrIcon = packed record
      Reserved: Word;
      wType: Word;
      Count: Word;
    end;

  type
    PIconRec = ^TIconRec;
    TIconRec = packed record
      Width: Byte;
      Height: Byte;
      Colors: Word;
      Reserved1: Word;
      Reserved2: Word;
      DIBSize: Longint;
      DIBOffset: Longint;
    end;

    procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var BI: TBitmapInfoHeader;
      Colors: Integer);
    var
      DS: TDIBSection;
      Bytes: Integer;
    begin
      DS.dsbmih.biSize := 0;
      Bytes := GetObject(Bitmap, SizeOf(DS), @DS);
      if Bytes = 0 then Abort         // ERROR
      else if (Bytes >= (sizeof(DS.dsbm) + sizeof(DS.dsbmih))) and
        (DS.dsbmih.biSize >= DWORD(sizeof(DS.dsbmih))) then
        BI := DS.dsbmih
      else
      begin
        FillChar(BI, sizeof(BI), 0);
        with BI, DS.dsbm do
        begin
          biSize := SizeOf(BI);
          biWidth := bmWidth;
          biHeight := bmHeight;
        end;
      end;
      case Colors of
        2: BI.biBitCount := 1;
        3..16:
          begin
            BI.biBitCount := 4;
            BI.biClrUsed := Colors;
          end;
        17..256:
          begin
            BI.biBitCount := 8;
            BI.biClrUsed := Colors;
          end;
      else
        BI.biBitCount := DS.dsbm.bmBitsPixel * DS.dsbm.bmPlanes;
      end;
      BI.biPlanes := 1;
      if BI.biClrImportant > BI.biClrUsed then
        BI.biClrImportant := BI.biClrUsed;
      if BI.biSizeImage = 0 then
        BI.biSizeImage := BytesPerScanLine(BI.biWidth, BI.biBitCount, 32) * Abs(BI.biHeight);
    end;

    procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: DWORD;
      var ImageSize: DWORD; Colors: Integer);
    var
      BI: TBitmapInfoHeader;
    begin
      InitializeBitmapInfoHeader(Bitmap, BI, Colors);
      if BI.biBitCount > 8 then
      begin
        InfoHeaderSize := SizeOf(TBitmapInfoHeader);
        if (BI.biCompression and BI_BITFIELDS) <> 0 then
          Inc(InfoHeaderSize, 12);
      end
      else
        if BI.biClrUsed = 0 then
          InfoHeaderSize := SizeOf(TBitmapInfoHeader) +
            SizeOf(TRGBQuad) * (1 shl BI.biBitCount)
        else
          InfoHeaderSize := SizeOf(TBitmapInfoHeader) +
            SizeOf(TRGBQuad) * BI.biClrUsed;
      ImageSize := BI.biSizeImage;
    end;

    function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
      var BitmapInfo; var Bits; Colors: Integer): Boolean;
    var
      OldPal: HPALETTE;
      DC: HDC;
    begin
      InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), Colors);
      OldPal := 0;
      DC := CreateCompatibleDC(0);
      try
        if Palette <> 0 then
        begin
          OldPal := SelectPalette(DC, Palette, False);
          RealizePalette(DC);
        end;
        Result := GetDIBits(DC, Bitmap, 0, TBitmapInfoHeader(BitmapInfo).biHeight, @Bits,
          TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0;
      finally
        if OldPal <> 0 then SelectPalette(DC, OldPal, False);
        DeleteDC(DC);
      end;
    end;

  var
    IconInfo: TIconInfo;
    MonoInfoSize, ColorInfoSize: DWORD;
    MonoBitsSize, ColorBitsSize: DWORD;
    MonoInfo, MonoBits, ColorInfo, ColorBits: Pointer;
    CI: TCursorOrIcon;
    List: TIconRec;
    Length: Longint;
  begin
    FillChar(CI, SizeOf(CI), 0);
    FillChar(List, SizeOf(List), 0);
    GetIconInfo(Icon, IconInfo);
    try
      InternalGetDIBSizes(IconInfo.hbmMask, MonoInfoSize, MonoBitsSize, 2);
      InternalGetDIBSizes(IconInfo.hbmColor, ColorInfoSize, ColorBitsSize, 0 {16 -> 0});
      MonoInfo := nil;
      MonoBits := nil;
      ColorInfo := nil;
      ColorBits := nil;
      try
        MonoInfo := AllocMem(MonoInfoSize);
        MonoBits := AllocMem(MonoBitsSize);
        ColorInfo := AllocMem(ColorInfoSize);
        ColorBits := AllocMem(ColorBitsSize);
        InternalGetDIB(IconInfo.hbmMask, 0, MonoInfo^, MonoBits^, 2);
        InternalGetDIB(IconInfo.hbmColor, 0, ColorInfo^, ColorBits^, 0 {16 -> 0});
        if WriteLength then
        begin
          Length := SizeOf(CI) + SizeOf(List) + ColorInfoSize +
            ColorBitsSize + MonoBitsSize;
          Stream.Write(Length, SizeOf(Length));
        end;

        with CI do
        begin
          CI.wType := RC3_ICON;
          CI.Count := 1;
        end;

        Stream.Write(CI, SizeOf(CI));

        with List, PBitmapInfoHeader(ColorInfo)^ do
        begin
          Width := biWidth;
          Height := biHeight;
          Colors := biPlanes * biBitCount;
          DIBSize := ColorInfoSize + ColorBitsSize + MonoBitsSize;
          DIBOffset := SizeOf(CI) + SizeOf(List);
        end;

        Stream.Write(List, SizeOf(List));

        with PBitmapInfoHeader(ColorInfo)^ do
          Inc(biHeight, biHeight); { color height includes mono bits }
        Stream.Write(ColorInfo^, ColorInfoSize);
        Stream.Write(ColorBits^, ColorBitsSize);
        Stream.Write(MonoBits^, MonoBitsSize);
      finally
        FreeMem(ColorInfo, ColorInfoSize);
        FreeMem(ColorBits, ColorBitsSize);
        FreeMem(MonoInfo, MonoInfoSize);
        FreeMem(MonoBits, MonoBitsSize);
      end;
    finally
      DeleteObject(IconInfo.hbmColor);
      DeleteObject(IconInfo.hbmMask);
    end;
  end;

function EnumResourceNamesProc(Module: HMODULE; ResType: PChar; ResName: PChar;
          lParam: TStringList): Integer; stdcall;
var
  ResourceName: String;
begin
  if HiWord(Cardinal(ResName)) = 0 then
    ResourceName := Format('%d', [LoWord(Cardinal(ResName))])
  else
    ResourceName := ResName;
  lParam.Add(ResourceName);
  Result := 1;
end;

procedure TForm1.LoadIcons(sFilename: String);
var
  hExe: THandle;
  SLIcons: TStringList;
  i: Integer;
  Icon: TIcon;
  ListItem: TListItem;
begin
  if LowerCase(ExtractFileExt(sFilename)) = '.ico' then
  begin
    ListView1.Clear;
    ListView1.Items.BeginUpdate;
    Icon := TIcon.Create;
    Icon.LoadFromFile(sFilename);
    ListItem := ListView1.Items.Add;
    ListItem.Caption := ExtractFileName(sFilename);
    ListItem.ImageIndex := ImageList1.AddIcon(Icon);
    Icon.Free;
    ListView1.Items.EndUpdate;
    Exit;
  end;
  SLIcons := TStringList.Create;
  hExe := LoadLibraryEx(PChar(sFilename), 0, LOAD_LIBRARY_AS_DATAFILE);

  if (hExe = 0) or (hExe = INVALID_HANDLE_VALUE) then
    Exit;

  EnumResourceNames(hExe, RT_GROUP_ICON, @EnumResourceNamesProc, Integer(SLIcons));
  FreeLibrary(hExe);
  ListView1.Clear;
  ListView1.Items.BeginUpdate;
  Icon := TIcon.Create;

  for i := 0 to SLIcons.Count -1 do
  begin
    Icon.Handle := ExtractIcon(hInstance, PChar(sFilename), i);
    ListItem := ListView1.Items.Add;
    ListItem.Caption := SLIcons[i];
    ListItem.ImageIndex := ImageList1.AddIcon(Icon);
  end;

  Icon.Free;
  ListView1.Items.EndUpdate;
  SLIcons.Free;
end;

procedure TForm1.Refresh1Click(Sender: TObject);
begin
  if not FileExists(Edit3.Text) then
    Exit;
  LoadIcons(Edit3.Text);
end;

procedure TForm1.Selectall1Click(Sender: TObject);
begin
  ListView1.SelectAll;
end;

function GetGroupIconFromIcoFile(const FileName: string;
         out GroupIcon: TSmoGroupIcon): Boolean;
var
  hFile: THandle;
  i, Size: Integer;
  Offsets: array of DWORD;
begin
  // clear the output record
  Finalize(GroupIcon);
  FillChar(GroupIcon.Header, SizeOf(GroupIcon.Header), 0);

  hFile := FileOpen(FileName, fmOpenRead or fmShareDenyNone);
  Result := hFile <> INVALID_HANDLE_VALUE;
  if Result then
  try
    // read header
    Size := SizeOf(GroupIcon.Header);
    Result := FileRead(hFile, GroupIcon.Header, Size) = Size;
    if not Result then Exit;
    with GroupIcon.Header do
      if (wReserved <> ICON_HEADER_RESERVED) or (wType <> ICON_HEADER_TYPE_ICO) then
      begin
        SetLastError(ERROR_BAD_FORMAT);
        Exit(False); // invalid data in header
      end;
    // read entries...
    // ico file entries are almost identical to TGroupIconRsrcEntry, with one small difference
    SetLength(GroupIcon.Entries, GroupIcon.Header.wCount);
    SetLength(Offsets, GroupIcon.Header.wCount);
    Size := SizeOf(GroupIcon.Entries[0]) - 2;
    for i := 0 to High(GroupIcon.Entries) do
    begin
      // read a TGroupIconRsrcEntry but without the last "wID" field
      Result := Result and (FileRead(hFile, GroupIcon.Entries[i], Size) = Size);
      // ico files have a dwFileOffset field there instead, read it separately
      Result := Result and (FileRead(hFile, Offsets[i], 4) = 4);
      GroupIcon.Entries[i].wID := i + 1;
    end;
    if not Result then Exit;
    // read icon image data
    SetLength(GroupIcon.IconData, GroupIcon.Header.wCount);
    for i := 0 to High(GroupIcon.IconData) do
    begin
      Size := GroupIcon.Entries[i].dwSize;
      SetLength(GroupIcon.IconData[i], Size);
      FileSeek(hFile, Offsets[i], FILE_BEGIN);
      Result := FileRead(hFile, GroupIcon.IconData[i, 0], Size) = Size;
      if not Result then Exit;
    end;
  finally
    FileClose(hFile);
    if not Result then
    begin
      // clear the output record
      Finalize(GroupIcon);
      FillChar(GroupIcon.Header, SizeOf(GroupIcon.Header), 0);
    end;
  end;
end;

// GetRsrcPointer: get pointer to the specified resource
// Returns nil on error
function GetRsrcPointer(hModule: HMODULE; lpName, lpType: PChar): Pointer;
var
  hResInfo: HRSRC;
  hResData: HGLOBAL;
begin
  Result := nil;
  hResInfo := FindResource(hModule, lpName, lpType);
  if hResInfo <> 0 then
  begin
    hResData := LoadResource(hModule, hResInfo);
    if hResData <> 0 then
      Result := LockResource(hResData);
    // UnlockResource & FreeResource are not necessary in 32 & 64 bit Windows
  end;
end;

// GetGroupIcon: get the complete data from the specified RT_GROUP_ICON resource.
// Returns true on success and false on error.
function GetGroupIcon(const FileName: string; GroupName: PChar; out GroupIcon: TSmoGroupIcon): Boolean;
var
  hLib: HMODULE;
  PData: Pointer;
  PEntry: PGroupIconRsrcEntry;
  LastError: DWORD;
  i: Integer;
begin
  // clear the output record
  Finalize(GroupIcon);
  FillChar(GroupIcon.Header, SizeOf(GroupIcon.Header), 0);

  hLib := LoadLibraryEx(PChar(FileName), 0, LOAD_LIBRARY_AS_DATAFILE);
  Result := hLib <> 0;
  if Result then
  try
    PData := GetRsrcPointer(hLib, PChar(GroupName), RT_GROUP_ICON);

    if not Assigned(PData) then Exit(False); // resource not found
    with PGroupIconRsrcHeader(PData)^ do
      if (wReserved <> ICON_HEADER_RESERVED) or (wType <> ICON_HEADER_TYPE_ICO) then
      begin
        SetLastError(ERROR_BAD_FORMAT);
        Exit(False); // invalid data in header
      end;
    // copy header
    GroupIcon.Header := PGroupIconRsrcHeader(PData)^;
    i := GroupIcon.Header.wCount;
    SetLength(GroupIcon.Entries, i);
    SetLength(GroupIcon.IconData, i);
    // copy entries & icon data
    PEntry := PGroupIconRsrcEntry(UIntPtr(PData) + SizeOf(TGroupIconRsrcHeader));
    for i := 0 to i - 1 do
    begin
      GroupIcon.Entries[i] := PEntry^;
      // load icon data (bitmap or PNG)
      PData := GetRsrcPointer(hLib, MakeIntResource(PEntry^.wID), RT_ICON);
      if Assigned(PData) then
      begin
        SetLength(GroupIcon.IconData[i], PEntry^.dwSize);
        Move(PData^, GroupIcon.IconData[i, 0], PEntry^.dwSize);
      end
      else // icon data wasn't found... wrong ID? Should not happen...
        GroupIcon.Entries[i].dwSize := 0;
      Inc(PEntry);
    end;
  finally
    LastError := GetLastError;
    FreeLibrary(hLib);
    if LastError <> ERROR_SUCCESS then SetLastError(LastError);
  end;
end;

function EnumResLangProc(hModule: HMODULE; lpszType, lpszName: PChar; wIDLanguage: Word;
  var LangArray: TWordDynArray): BOOL; stdcall;
var
  i: Integer;
begin
  i := Length(LangArray);
  SetLength(LangArray, i + 1);
  LangArray[i] := wIDLanguage;
  Result := True;
end;

function GetResourceLangIDs(hModule: HMODULE; lpType, lpName: PChar): TWordDynArray;
begin
  Result := nil;
  if not EnumResourceLanguages(hModule, lpType, lpName, @EnumResLangProc, IntPtr(@Result)) then
    Result := nil;
end;

// DeleteIconGroup: deletes the specified RT_GROUP_ICON resource and the referenecd RT_ICON
// resources. Deletes ALL language versions, if several exist.
// Returns true if the resource does not exist or was deleted successfully.
// Returns false if an error occured.
function DeleteGroupIcon(const FileName: string; GroupName: PChar): Boolean;
var
  GroupIcon: TSmoGroupIcon;
  hUpdate: THandle;
  hLib: HMODULE;
  LastError: DWORD;
  i, n: Integer;
  LangArray: TWordDynArray;
begin
  Result := GetGroupIcon(FileName, GroupName, GroupIcon);
  if not Result then
  begin
    case GetLastError of
      ERROR_RESOURCE_DATA_NOT_FOUND,
      ERROR_RESOURCE_TYPE_NOT_FOUND,
      ERROR_RESOURCE_NAME_NOT_FOUND,
      ERROR_RESOURCE_LANG_NOT_FOUND: Result := True;
    end;
    Exit;
  end;
  Assert(GroupIcon.Header.wCount = Length(GroupIcon.Entries));

  hLib := 0;
  hUpdate := 0;
  try
    hUpdate := BeginUpdateResource(PChar(FileName), False);
    if hUpdate <> 0 then
      hLib := LoadLibraryEx(PChar(FileName), 0, LOAD_LIBRARY_AS_DATAFILE);
    Result := (hUpdate <> 0) and (hLib <> 0);
    if not Result then Exit;

    // delete the RT_GROUP_ICON, all languages
    LangArray := GetResourceLangIDs(hLib, RT_GROUP_ICON, PChar(GroupName));
    for n := 0 to High(LangArray) do
      Result := Result and UpdateResource(hUpdate, RT_GROUP_ICON, PChar(GroupName),
        LangArray[n], nil, 0);
    // delete the actual icon data (RT_ICON), all languages
    // TODO: check if we're actually allowed to do that... other RT_GROUP_ICON could still
    // be referencing some of these RT_ICON we're about to delete!
    for i := 0 to High(GroupIcon.Entries) do
    begin
      if not Result then Break;
      LangArray := GetResourceLangIDs(hLib, RT_ICON, MakeIntResource(GroupIcon.Entries[i].wID));
      for n := 0 to High(LangArray) do
        Result := Result and UpdateResource(hUpdate, RT_ICON,
          MakeIntResource(GroupIcon.Entries[i].wID), LangArray[n], nil, 0);
    end;
  finally
    LastError := GetLastError;
    if hLib <> 0 then FreeLibrary(hLib);
    if hUpdate <> 0 then EndUpdateResource(hUpdate, not Result);
    if LastError <> ERROR_SUCCESS then SetLastError(LastError);
  end;
end;

// FindUnusedIconID: returns the first unused RT_ICON resource ID in the specified module.
// A return value of 0 means that no unused ID could be found.
function FindUnusedIconID(const hModule: HMODULE; const StartID: Word = 0): Word;
var
  hResInfo: HRSRC;
begin
  Result := StartID;
  if Result = 0 then Inc(Result);
  while Result > 0 do
  begin
    hResInfo := FindResource(hModule, MakeIntResource(Result), RT_ICON);
    if hResInfo = 0 then Break;
    Inc(Result);
  end;
end;

// SetGroupIcon: set the complete data of the specified RT_GROUP_ICON resource, and add the
// referenced RT_ICON resources. If a RT_GROUP_ICON of the same name exists, it'll be deleted
// first, including all RT_ICON resources it references.
// Returns true on success and false on error.
function SetGroupIcon(const FileName: string; GroupName: PChar;
                      var GroupIcon: TSmoGroupIcon): Boolean;
var
  hLib: HMODULE;
  hUpdate: THandle;
  PData: Pointer;
  LastError: DWORD;
  i, SizeOfEntries: Integer;
  wLanguage, IconID: Word;
begin
{$R-}
  Assert(GroupIcon.Header.wCount = Length(GroupIcon.Entries));
  Assert(Length(GroupIcon.Entries) = Length(GroupIcon.IconData));
  // if the group already exists, then delete it first
  Result := DeleteGroupIcon(FileName, GroupName);
  hLib := 0;
  hUpdate := 0;
  PData := nil;
  if Result then
  try
    hUpdate := BeginUpdateResource(PChar(FileName), False);
    if hUpdate <> 0 then
      hLib := LoadLibraryEx(PChar(FileName), 0, LOAD_LIBRARY_AS_DATAFILE);
    Result := (hUpdate <> 0) and (hLib <> 0);
    if not Result then Exit;

    wLanguage := MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL);
    IconID := 0;
    // add the RT_ICON data
    for i := 0 to High(GroupIcon.Entries) do
    begin
      // find the next unused ID
      IconID := FindUnusedIconID(hLib, IconID + 1);
      Result := Result and (IconID > 0) and
        UpdateResource(hUpdate, RT_ICON, MakeIntResource(IconID), wLanguage,
        @GroupIcon.IconData[i, 0], Length(GroupIcon.IconData[i]));
      // update the entry's ID with the new value
      GroupIcon.Entries[i].wID := IconID;
    end;
    // add the RT_GROUP_ICON data
    if Result then
    begin
      // copy data from the GroupIcon structure to a contiguous block of memory
      i := SizeOf(GroupIcon.Header);
      SizeOfEntries := GroupIcon.Header.wCount * SizeOf(GroupIcon.Entries[0]);
      GetMem(PData, i + SizeOfEntries);
      PGroupIconRsrcHeader(PData)^ := GroupIcon.Header;
      Move(GroupIcon.Entries[0], Pointer(IntPtr(PData) + i)^, SizeOfEntries);
      Result := UpdateResource(hUpdate, RT_GROUP_ICON, PChar(GroupName), wLanguage,
        PData, i + SizeOfEntries);
    end;
  finally
    LastError := GetLastError;
    if Assigned(PData) then FreeMem(PData);
    if hLib <> 0 then FreeLibrary(hLib);
    if hUpdate <> 0 then EndUpdateResource(hUpdate, not Result);
    if LastError <> ERROR_SUCCESS then SetLastError(LastError);
  end;
  {$R+}
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   Icon : TIcon;
   Bmp : TBitmap;
begin
  if Image1.Picture.Graphic = nil then
  begin
    MessageDlg('No Picture Data found!',mtInformation, [mbOK], 0);
    Exit;
  end;

  if SaveDialog1.Execute then
  begin
   if SaveDialog1.FilterIndex = 1 then
    begin
      try
        Icon := TIcon.Create;
        Bmp := TBitmap.Create;
        Icon.Assign(Image1.Picture.Graphic);
        Bmp.Width := Icon.Width;
        Bmp.Height := Icon.Height;
        Bmp.Canvas.Draw(0, 0, Icon ) ;

        if CheckBox1.Checked = true then
        begin
          Bmp.TransparentColor := clBlack;
          Bmp.Transparent := true;
        end;

        Bmp.SaveToFile(SaveDialog1.FileName + '.bmp');
      finally
        Icon.Free;
        Bmp.Free;
      end;
    end;

   if SaveDialog1.FilterIndex = 2 then
    begin
      try
        Image1.Picture.Icon.SaveToFile(SaveDialog1.FileName + '.ico');
      except
        on E: Exception do
        ShowMessage('Draw Icon failed : ' + E.Message);
      end;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if OpenDialog3.Execute then
  begin
    Edit3.Text := OpenDialog3.FileName;
    LoadIcons(Edit3.Text);
    Label14.Caption := IntToStr(ListView1.Items.Count) + '  Icon(s) found!';

    StatusBar1.Panels[1].Text := ExtractFileName(OpenDialog3.FileName);
    StatusBar1.Panels[3].Text := ExtractFileExt(OpenDialog3.FileName);
    StatusBar1.Panels[5].Text := IntToStr(Get_File_Size4(OpenDialog3.FileName) div 1000) + ' Kb';
    StatusBar1.Panels[7].Text := '0x0';

    Refresh1.Enabled := true;
    ExtractIcon1.Enabled := true;
    Clear1.Enabled := true;
    Selectall1.Enabled := true;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  IconA, IconB, IconC: TSmoGroupIcon;
  AGroupIcon: TSmoGroupIcon;
begin
  if (Edit1.Text = '') or (Edit2.Text = '') then
  begin
    MessageDlg('No Source or Destination file found!',mtInformation, [mbOK], 0);
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  case ComboBox1.ItemIndex of
  0 : begin
        if ComboBox2.ItemIndex = 0 then begin
          // Retrieve the symbol group "ICO_MYCOMPUTER" from exe
          if not GetGroupIcon(Edit1.Text, 'MAINICON', IconA) then
                RaiseLastOSError;

          // Save the icon group in Test.exe under the name "MAINICON"
          if not SetGroupIcon(Edit2.Text, 'MAINICON', IconA) then
            RaiseLastOSError;
        end;

        if ComboBox2.ItemIndex = 1 then begin
          // Retrieve the symbol group "ICO_MYCOMPUTER" from exe
          if not GetGroupIcon(Edit1.Text, 'MAINICON', IconB) then
                RaiseLastOSError;

          // Save the icon group in Test.exe under the name "MAINICON"
          if not SetGroupIcon(Edit2.Text, 'MAINICON', IconB) then
            RaiseLastOSError;
        end;

        if ComboBox2.ItemIndex = 2 then begin
          // Retrieve the symbol group "ICO_MYCOMPUTER" from exe
          if not GetGroupIcon(Edit1.Text, 'MAINICON', IconC) then
                RaiseLastOSError;

          // Save the icon group in Test.exe under the name "MAINICON"
          if not SetGroupIcon(Edit2.Text, 'MAINICON', IconC) then
            RaiseLastOSError;
        end;
      end;

  1 : begin
        if ComboBox2.ItemIndex = 0 then begin
          // Load an icon group from an ICO file
          if not GetGroupIconFromIcoFile(Edit1.Text, IconA) then
            RaiseLastOSError;

          if not SetGroupIcon(Edit2.Text, 'MAINICON', IconA) then
            RaiseLastOSError;
        end;

        if ComboBox2.ItemIndex = 1 then begin
          // Load an icon group from an ICO file
          if not GetGroupIconFromIcoFile(Edit1.Text, IconB) then
            RaiseLastOSError;

          if not SetGroupIcon(Edit2.Text, 'MAINICON', IconB) then
            RaiseLastOSError;
        end;

        if ComboBox2.ItemIndex = 2 then begin
          // Load an icon group from an ICO file
          if not GetGroupIconFromIcoFile(Edit1.Text, IconC) then
            RaiseLastOSError;

          if not SetGroupIcon(Edit2.Text, 'MAINICON', IconC) then
            RaiseLastOSError;
        end;
      end;

  2 : begin
        if ComboBox2.ItemIndex = 3 then begin
          // Retrieve the symbol group "ICO_MYCOMPUTER" from exe
          if not GetGroupIcon(Edit1.Text, 'MAINICON', IconA) then
            RaiseLastOSError;
          // Retrieve the symbol group with ID 2 from exe
          if not GetGroupIcon(Edit1.Text, MakeIntResource(2), IconB) then
            RaiseLastOSError;
          // Load an icon group from an ICO file
          if not GetGroupIconFromIcoFile(Edit1.Text, IconC) then
            RaiseLastOSError;


          // Save the symbol groups in exe under different names/IDs.
          if not (SetGroupIcon(Edit2.Text, 'MAINICON', IconA)
            and SetGroupIcon(Edit2.Text, MakeIntResource(123), IconB)
            and SetGroupIcon(Edit2.Text, 'A', IconC)) then
            RaiseLastOSError;
        end;
      end;
  end;
  Sleep(100);
  Screen.Cursor := crDefault;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  case ComboBox1.ItemIndex of
  0 : begin
        if OpenDialog1.Execute then
          begin
           Edit2.Text := OpenDialog1.FileName;
          end;
        end;
  1 : begin
        if OpenDialog1.Execute then
          begin
           Edit2.Text := OpenDialog1.FileName;
          end;
        end;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  myIcon: TIcon;
begin
  case ComboBox1.ItemIndex of
      0 : begin
          if OpenDialog1.Execute then
            begin
              myIcon := TIcon.Create;
                try
                  Edit1.Text := OpenDialog1.FileName;
                  // get icon data from exe resource
                  myIcon.Handle := ExtractIcon(hInstance,
                                        PChar(OpenDialog1.FileName), 0);
                  // set image dimensions
                  Image1.Height := MyIcon.Height;
                  Image1.Width := MyIcon.Width;

                  if CheckBox1.Checked = true then
                  begin
                    Image1.Transparent := true;
                  end;

                  // show icon data in image
                  Image1.Picture.Icon := myIcon;

                  StatusBar1.Panels[1].Text := ExtractFileName(OpenDialog1.FileName);
                  StatusBar1.Panels[3].Text := ExtractFileExt(OpenDialog1.FileName);
                  StatusBar1.Panels[5].Text := IntToStr(Get_File_Size4(OpenDialog1.FileName) div 1000) + ' Kb';
                  StatusBar1.Panels[7].Text := IntToStr(Image1.Picture.Icon.Height) + 'x' +
                                               IntToStr(Image1.Picture.Icon.Width);
                finally
                  MyIcon.Free;
                end;
            end;
          end;

      1 : begin
            if OpenDialog2.Execute then
              begin
               Edit1.Text := OpenDialog2.FileName;
               try
                Image1.Picture.LoadFromFile(OpenDialog2.FileName);
               finally
                 StatusBar1.Panels[1].Text := ExtractFileName(OpenDialog2.FileName);
                 StatusBar1.Panels[3].Text := ExtractFileExt(OpenDialog2.FileName);
                 StatusBar1.Panels[5].Text := IntToStr(Get_File_Size4(OpenDialog2.FileName) div 1000) + ' Kb';
                 StatusBar1.Panels[7].Text := IntToStr(Image1.Picture.Icon.Height) + 'x' +
                                               IntToStr(Image1.Picture.Icon.Width);
               end;
              end;
          end;
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  FileName :  array[0..MAX_PATH - 1] of WideChar;
  Size, Index: LongInt;
  hLargeIcon, hSmallIcon : HIcon;
  Stream: TFileStream;
begin
  Size := MAX_PATH;
  StringToWideChar('%SystemRoot%\system32\Shell32.dll', FileName, MAX_PATH);
  If PickIconDlgW(Self.Handle, FileName, Size, Index) Then
    If (Index <> -1) Then
    If ExtractIconExW( FileName, Index, hLargeIcon, hSmallIcon, 1) > 0 Then
    Begin
      Stream := TFileStream.Create(ExtractFilePath(Application.ExeName) + 'Data\Shell\icon.ico', fmCreate);
      try
        WriteIcon(Stream, hLargeIcon);
      finally
        Stream.Free;
        DestroyIcon(hLargeIcon);
        DestroyIcon(hSmallIcon);
        Image3.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Data\Shell\icon.ico');
      end;
    End;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
   Icon : TIcon;
   Bmp : TBitmap;
begin
  if (Edit4.Text = '') or (Image3.Picture.Graphic = nil) then
  begin
    MessageDlg('No Graphic or Destination EXE file found!',mtInformation, [mbOK], 0);
    Exit;
  end;

  if SaveDialog1.Execute then
  begin
   if SaveDialog1.FilterIndex = 1 then
    begin
      try
        Icon := TIcon.Create;
        Bmp := TBitmap.Create;
        Icon.Assign(Image3.Picture.Graphic);
        Bmp.Width := Icon.Width;
        Bmp.Height := Icon.Height;
        Bmp.Canvas.Draw(0, 0, Icon ) ;

        if CheckBox2.Checked = true then
        begin
          Bmp.TransparentColor := clBlack;
          Bmp.Transparent := true;
        end;

        Bmp.SaveToFile(SaveDialog1.FileName + '.bmp');
      finally
        Icon.Free;
        Bmp.Free;
      end;
    end;

   if SaveDialog1.FilterIndex = 2 then
    begin
      try
        Image3.Picture.Icon.SaveToFile(SaveDialog1.FileName + '.ico');
      except
        on E: Exception do
        ShowMessage('Draw Icon failed : ' + E.Message);
      end;
    end;
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  IconA : TSmoGroupIcon;
begin
  if (Edit4.Text = '') or (Image3.Picture.Graphic = nil) then
  begin
    MessageDlg('No Graphic or Destination EXE file found!',mtInformation, [mbOK], 0);
    Exit;
  end;

  Screen.Cursor := crHourGlass;

  // Load an icon group from an ICO file
  if not GetGroupIconFromIcoFile(ExtractFilePath(Application.ExeName) +
                                'Data\Shell\icon.ico', IconA) then
    RaiseLastOSError;

  if not SetGroupIcon(Edit4.Text, 'MAINICON', IconA) then
    RaiseLastOSError;

  Sleep(100);
  Screen.Cursor := crDefault;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Edit4.Text := OpenDialog1.FileName;

    if CheckBox1.Checked = true then
    begin
    Image1.Transparent := true;
    end;

    StatusBar1.Panels[1].Text := ExtractFileName(OpenDialog1.FileName);
    StatusBar1.Panels[3].Text := ExtractFileExt(OpenDialog1.FileName);
    StatusBar1.Panels[5].Text := IntToStr(Get_File_Size4(OpenDialog1.FileName) div 1000) + ' Kb';
    StatusBar1.Panels[7].Text := '0x0';
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked = true then
  begin
    Image1.Transparent := true;
  end else begin
    Image1.Transparent := false;
  end;
end;

procedure TForm1.Clear1Click(Sender: TObject);
begin
  ListView1.Clear;
  Edit3.Clear;
  StatusBar1.Panels[1].Text := '-';
  StatusBar1.Panels[3].Text := '-';
  StatusBar1.Panels[5].Text := '0 Kb';
  StatusBar1.Panels[7].Text := '0x0';
  Label14.Caption := 'Select Supported files..';
  Refresh1.Enabled := false;
  ExtractIcon1.Enabled := false;
  Clear1.Enabled := false;
  Selectall1.Enabled := false;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  Edit1.Clear;
  Edit2.Clear;
  StatusBar1.Panels[1].Text := '-';
  StatusBar1.Panels[3].Text := '-';
  StatusBar1.Panels[5].Text := '0 Kb';
  StatusBar1.Panels[7].Text := '0x0';
  Image1.Picture.Graphic := nil;
end;

procedure TForm1.ExtractIcon1Click(Sender: TObject);
const
  sMulti = '%s%s.ico';
  sExtracted = '%d Icon(s) Extracted!';
var
  i: Integer;
  SL: TStringList;
begin
  if ListView1.Selected = nil then
    Exit;
  if not FileExists(Edit3.Text) then
    Exit;
  if SaveDialog2.Execute then
  begin
    if LowerCase(ExtractFileExt(SaveDialog2.FileName)) <> '.ico' then
      SaveDialog2.FileName := SaveDialog2.FileName + '.ico';
    SL := TStringList.Create;
    SL.BeginUpdate;
    for i := 0 to ListView1.Items.Count -1 do
    begin
      if ListView1.Items[i].Selected then
        SL.Add(ListView1.Items[i].Caption);
    end;
    SL.EndUpdate;
    if SL.Count = 1 then
    begin
      untIcons.ExtractIconFromFile(Edit3.Text, SaveDialog2.FileName, SL[0]);
    end else
    if SL.Count > 1 then
    begin
      for i := 0 to SL.Count -1 do
      begin
        untIcons.ExtractIconFromFile(Edit3.Text, Format(sMulti,
                        [ExtractFilePath(SaveDialog2.FileName), SL[i]]), SL[i]);;
      end;
    end;
    MessageBox(Handle, PChar(Format(sExtracted,
              [SL.Count])), 'Icon Extractor', MB_ICONINFORMATION);
    SL.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  SHFileInfo: TSHFileInfo;
  hIcon: THandle;
begin
  Form1.DoubleBuffered := true;
  hIcon := SHGetFileInfo(PChar(Copy(ParamStr(0), 1, 3)), 0,
                               SHFileInfo,
                               sizeof(SHFileInfo),
                               SHGFI_SYSICONINDEX or SHGFI_ICON);
  DestroyIcon(SHFileInfo.hIcon);
  ImageList1.Handle := hIcon;
  ImageList1.Clear;
  LoadIcons(Edit3.Text);
end;

end.
