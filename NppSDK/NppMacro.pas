unit NppMacro;

//{$I Notpad_Plugin.inc}

interface

uses
  Windows, NppPluginInc, Scintilla, System.SysUtils;

  function Npp_AddToolBarIcon(hWd: HWND; CmdID: UINT; icon: TToolbarIcons): Integer;
  function Npp_MsgToPlugin(hWd: HWND; destModuleName: PTCHAR; var info: TCommunicationInfo): Boolean;
  function Npp_GetPluginsConfigDir(hWd: HWND): string;
  function Npp_SetMenuItemCheck(hWd: HWND; CmdId: ULONG; Checked: Boolean): Integer;

  // Language
  function Npp_GetCurrentLangType(hWd: HWND): TLangType;
  function Npp_SetCurrentLangType(hWd: HWND; Lang: TLangType): Integer;

  // File
  function Npp_GetCurrentFileOf(hWd: HWND; MSG: ULONG):string;
  function Npp_GetCurrentFileName(hWd: HWND): string;
  function Npp_GetCurrentShortFileName(hWd: HWND): string;
  function Npp_GetCurrentFileDir(hWd: HWND): string;

  // Scintilla Editor
  function Npp_GetCurrentScintilla(hWd: HWND): Integer;
  function Npp_GetCurrentScintillaHandle(NppData: TNppData): HWND;
  function Npp_SciReplaceSel(ScinthWd: HWND; Text: string): Integer;
  function Npp_SciAppedText(ScinthWd: HWND; AText: TBytes): Integer;
  function Npp_SciSetText(ScinthWd: HWND; AText: TBytes): Integer;
  function Npp_SciGetText(ScinthWd: HWND): TBytes;
  function Npp_SciGoToPos(ScinthWd: HWND; Posi: Integer): Integer;
  function Npp_SciGetLength(ScinthWd: HWND): Integer;
  function Npp_SciSetZoomLevel(ScinthWd: HWND; Level: Integer): Integer;
  function Npp_SciGetZoomLevel(ScinthWd: HWND): Integer;
  function Npp_SciEnSureVisible(ScinthWd: HWND; Line: Integer): Integer;
  function Npp_SciGetLine(Scinthnd: HWND): Integer;
  function Npp_SciGoToLine(ScinthWd: HWND; Line: Integer): Integer;
  function Npp_SciGetSelText(ScinthWd: HWND): TBytes;


  // Codeing
  function Npp_GetCurrentCodePage(ScinthWd: HWND): Integer;

  // MenuCmd
  //  File
  function Npp_MenuCmdOf(hWd: HWND; Cmd: Integer): Integer;
  function Npp_FileNew(hWd: HWND): Integer;
  function Npp_FileOpen(hWd: HWND): Integer;
  function Npp_FileClose(hWd: HWND): Integer;
  function Npp_FileCloseAll(hWd: HWND): Integer;
  function Npp_FileCloseAllNotCurrent(hWd: HWND): Integer;
  function Npp_FileSave(hWd: HWND): Integer;
  function Npp_FileSaveAll(hWd: HWND): Integer;
  function Npp_FileSaveAs(hWd: HWND): Integer;
  function Npp_FileAsianLang(hWd: HWND): Integer;
  function Npp_FilePrint(hWd: HWND): Integer;
  function Npp_FilePrintNow(hWd: HWND): Integer;
  function Npp_FileExit(hWd: HWND): Integer;
  function Npp_FileLoadSession(hWd: HWND): Integer;
  function Npp_FileSaveSession(hWd: HWND): Integer;
  function Npp_FileReLoad(hWd: HWND): Integer;
  function Npp_FileSaveCopyAs(hWd: HWND): Integer;
  function Npp_FileDelete(hWd: HWND): Integer;
  function Npp_FileReName(hWd: HWND): Integer;
  //   Edit
  function Npp_EditCut(hWd: HWND): Integer;
  function Npp_EditCopy(hWd: HWND): Integer;
  function Npp_EditUndo(hWd: HWND): Integer;
  function Npp_EditRedo(hWd: HWND): Integer;
  function Npp_EditPaste(hWd: HWND): Integer;
  function Npp_EditDelete(hWd: HWND): Integer;
  function Npp_EditSeleteAll(hWd: HWND): Integer;
  
  // Dock Dialog
  function Npp_DockDialogAdd(hWd, SubhWd: HWND): Integer;
  function Npp_DockDialogRemove(hWd, SubhWd: HWND): Integer;
  function Npp_DockDialogRegister(hWd: HWND; Data: TtTbData):Integer;
  function Npp_DockDialogUpdateDisplay(hWd, SubhWd: HWND): Integer;
  function Npp_DockDialogShow(hWd, SubhWd: HWND): Integer;
  function Npp_DockDialogHide(hWd, SubhWd: HWND): Integer;
implementation

  function Npp_AddToolBarIcon(hWd: HWND; CmdID: UINT; icon: TToolbarIcons): Integer;
  begin
    Result := SendMessage(hWd, NPPM_ADDTOOLBARICON, CmdID, LPARAM(@icon));
  end;

  function Npp_MsgToPlugin(hWd: HWND; destModuleName: PTCHAR; var info: TCommunicationInfo): Boolean;
  begin
    Result := SendMessage(hWd, NPPM_MSGTOPLUGIN, WPARAM(destModuleName), LPARAM(@info)) <> 0;
  end;

  function Npp_GetPluginsConfigDir(hWd: HWND): string;
  var
    LDir: array[0..MAX_PATH-1] of UCHAR;
  begin
    FillChar(LDir, SizeOf(LDir), 0);
    SendMessage(hWd, NPPM_GETPLUGINSCONFIGDIR, MAX_PATH, LParam(@LDir[0]));
    Result := LDir;
  end;

  function Npp_SetMenuItemCheck(hWd: HWND; CmdId: ULONG; Checked: Boolean): Integer;
  begin
    Result := SendMessage(hWd, NPPM_SETMENUITEMCHECK, CmdId, Integer(Checked));
  end;  

  // Language
  function Npp_GetCurrentLangType(hWd: HWND): TLangType;
  var
    Value: Integer;
  begin
    Value := 1;
    SendMessage(hWd, NPPM_GETCURRENTLANGTYPE, 0, LPARAM(@Value));
    if Value = -1 then
      Result := L_TXT
    else
      Result := TLangType(Value);
  end;
  
  function Npp_SetCurrentLangType(hWd: HWND; Lang: TLangType): Integer;
  var
    Value: Integer;
  begin
    Value := Integer(Lang);
    Result := SendMessage(hWd, NPPM_SETCURRENTLANGTYPE, 0, Value);
  end;  

  // File
  function Npp_GetCurrentFileOf(hWd: HWND; MSG: ULONG):string;
  var
    Path: array[0..MAX_PATH-1] of UCHAR;
  begin
    SendMessage(hWd, MSG, 0, LPARAM(@path[0]));
    Result := Path;
  end;
   
  function Npp_GetCurrentFileName(hWd: HWND): string;
  begin
    Result := Npp_GetCurrentFileOf(hWd, NPPM_GETFULLCURRENTPATH);
  end;

  function Npp_GetCurrentShortFileName(hWd: HWND): string;
  begin
    Result := Npp_GetCurrentFileOf(hWd, NPPM_GETFILENAME);
  end;

  function Npp_GetCurrentFileDir(hWd: HWND): string;
  begin
    Result := Npp_GetCurrentFileOf(hWd, NPPM_GETCURRENTDIRECTORY);
  end;

  // Editor
  function Npp_GetCurrentScintilla(hWd: HWND): Integer;
  begin
    Result := -1;
    SendMessage(hWd, NPPM_GETCURRENTSCINTILLA, 0, LParam(@Result));
  end;

  function Npp_GetCurrentScintillaHandle(NppData: TNppData): HWND;
  begin
    if Npp_GetCurrentScintilla(NppData._nppHandle) = 0 then
       Result := NppData._scintillaMainHandle
    else Result := NppData._scintillaSecondHandle;
  end;

  function Npp_SciReplaceSel(ScinthWd: HWND; Text: string): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_REPLACESEL, 0, LParam(PAnsiChar(Text)));
  end;

  function Npp_SciAppedText(ScinthWd: HWND; AText: TBytes): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_APPENDTEXT, 1, LParam(@AText[0]));
  end;

  function Npp_SciSetText(ScinthWd: HWND; AText: TBytes): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_SETTEXT, 0, LParam(@AText[0]));
  end;

  function Npp_SciGetText(ScinthWd: HWND): TBytes;
  var
    Len: Integer;
  begin
    Len := Npp_SciGetLength(ScinthWd);
    SetLength(Result, Len);
    if Len > 0 then
      SendMessage(ScinthWd, SCI_GETTEXT, Len, LPARAM(@Result[0]));
  end;
  // SCI_GETCURRENTPOS
  function Npp_SciGoToPos(ScinthWd: HWND; Posi: Integer): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_GOTOPOS, Posi, 0);
  end;

  function Npp_SciGetLength(ScinthWd: HWND): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_GETLENGTH, 0, 0);
  end;

  function Npp_SciSetZoomLevel(ScinthWd: HWND; Level: Integer): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_SETZOOM, Level, 0);
  end;

  function Npp_SciGetZoomLevel(ScinthWd: HWND): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_GETZOOM, 0, 0);
  end;

  function Npp_SciEnSureVisible(ScinthWd: HWND; Line: Integer): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_ENSUREVISIBLE, Line - 1, 0);
  end;

  function Npp_SciGetLine(Scinthnd: HWND): Integer;
  begin
    Result := SendMessage(Scinthnd, SCI_GETLINE, 0, 0) + 1;
  end;  

  function Npp_SciGoToLine(ScinthWd: HWND; Line: Integer): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_GOTOLINE, Line - 1, 0);
  end;  

  function Npp_SciGetSelText(ScinthWd: HWND): TBytes;
  var
    Len: Integer;
  begin
    Len := Npp_SciGetLength(ScinthWd);
    SetLength(Result, Len);
    if Len > 0 then
      SendMessage(ScinthWd, SCI_GETSELTEXT, Len, LPARAM(@Result[0]));
  end;

  // Coding
  function Npp_GetCurrentCodePage(ScinthWd: HWND): Integer;
  begin
    Result := SendMessage(ScinthWd, SCI_GETCODEPAGE, 0, 0);
  end;

  // MenuCmd
  //  File
  function Npp_MenuCmdOf(hWd: HWND; Cmd: Integer): Integer;
  begin
    Result := SendMessage(hWd, NPPM_MENUCOMMAND, 0, Cmd);
  end;  

  function Npp_FileNew(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_NEW);
  end;

  function Npp_FileOpen(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_OPEN);
  end;

  function Npp_FileClose(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_CLOSE)
  end;

  function Npp_FileCloseAll(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_CLOSEALL)
  end;

  function Npp_FileCloseAllNotCurrent(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_CLOSEALL_BUT_CURRENT);
  end;  

  function Npp_FileSave(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_SAVE);
  end;

  function Npp_FileSaveAll(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_SAVEALL);
  end;

  function Npp_FileSaveAs(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_SAVEAS);
  end;

  function Npp_FileAsianLang(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_ASIAN_LANG);
  end;

  function Npp_FilePrint(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_PRINT);
  end;

  function Npp_FilePrintNow(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_PRINTNOW);
  end;

  function Npp_FileExit(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_EXIT);
  end;

  function Npp_FileLoadSession(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_LOADSESSION);
  end;

  function Npp_FileSaveSession(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_SAVESESSION);
  end;

  function Npp_FileReLoad(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_RELOAD);
  end;

  function Npp_FileSaveCopyAs(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_SAVECOPYAS);
  end;

  function Npp_FileDelete(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_DELETE);
  end;

  function Npp_FileReName(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_FILE_RENAME);
  end;
  //  Edit
  function Npp_EditCut(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_EDIT_CUT);
  end;

  function Npp_EditCopy(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_EDIT_COPY);
  end;

  function Npp_EditUndo(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_EDIT_UNDO);
  end;

  function Npp_EditRedo(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_EDIT_REDO);
  end;

  function Npp_EditPaste(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_EDIT_PASTE);
  end;

  function Npp_EditDelete(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_EDIT_DELETE);
  end;

  function Npp_EditSeleteAll(hWd: HWND): Integer;
  begin
    Result := Npp_MenuCmdOf(hWd, IDM_EDIT_SELECTALL);
  end;
    
  // Dock Dialog
  function Npp_DockDialogAdd(hWd, SubhWd: HWND): Integer;
  begin
    Result := SendMessage(hWd, NPPM_MODELESSDIALOG, MODELESSDIALOGADD, SubhWd);
  end;

  function Npp_DockDialogRemove(hWd, SubhWd: HWND): Integer;
  begin
    Result := SendMessage(hWd, NPPM_MODELESSDIALOG, MODELESSDIALOGREMOVE, SubhWd);
  end;

  function Npp_DockDialogRegister(hWd: HWND; Data: TtTbData):Integer;
  begin
    Result := SendMessage(hWd, NPPM_DMMREGASDCKDLG, 0, LPARAM(@Data));
  end;

  function Npp_DockDialogUpdateDisplay(hWd, SubhWd: HWND): Integer;
  begin
    Result := SendMessage(hWd, NPPM_DMMUPDATEDISPINFO, 0, hWd);
  end;

  function Npp_DockDialogShow(hWd, SubhWd: HWND): Integer;
  begin
    Result := SendMessage(hWd, NPPM_DMMSHOW, 0, SubhWd);
  end;
  
  function Npp_DockDialogHide(hWd, SubhWd: HWND): Integer;
  begin
    Result := SendMessage(hWd, NPPM_DMMHIDE, 0, SubhWd);
  end;  
end.
