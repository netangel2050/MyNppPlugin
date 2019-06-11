unit PluginDefinition;

{$I Notpad_Plugin.inc}

interface

uses
  Windows, Classes, Messages, SysUtils, NppPluginClass, NppPluginInc, Scintilla,
  Dialogs, System.Generics.Collections, Vcl.Menus, System.Variants, IdHTTP;

type
  TNppPluginEx = class(TNppPlugin)
  private
    FPm: TPopupMenu;
    procedure AddNewMenu(ACaption: string; AFunc: Pointer);
    procedure OnMenuItemClick(Sender: TObject);
  public
    constructor Create;  
    destructor Destroy; override;
    procedure commandMenuInit; override;
    procedure beNotified(var notifyCode: TSCNotification);override;
  end;

var
  MyNppPlugin: TNppPluginEx;



implementation

uses
  NppMacro, uConvOptions, IdURI, HttpSession, System.JSON;

var
  uTypeConvList: TDictionary<string, string>;


function ConvType(AType: string): string;
begin
  if AType = '' then
    Result := '';
  if not uTypeConvList.TryGetValue(AType, Result) then
    Result := AType;
end;  

function GetCurrentNppText: string;
var
  LhWd: HWND;
  LBytes: TBytes;
begin
  Result := '';
  LhWd := Npp_GetCurrentScintillaHandle(MyNppPlugin.NppData);
  if not IsWindow(LhWd) then
    Exit;
  LBytes := Npp_SciGetText(LhWd);
  if Length(LBytes) > 0 then
    Result := TEncoding.UTF8.GetString(LBytes);
end;


procedure SetNewPageNppText(AText: string);
var
  LStream: TStringStream;
begin
  LStream := TStringStream.Create(AText+#0, TEncoding.UTF8);
  try
    Npp_FileNew(MyNppPlugin.NppHandle);
    Npp_SciSetText(Npp_GetCurrentScintillaHandle(MyNppPlugin.NppData), LStream.Bytes);
  finally
    LStream.Free;
  end;
end;


function GetCurrentNppSelectText: string;
var
  LhWd: HWND;
  LBytes: TBytes;
begin
  Result := '';
  LhWd := Npp_GetCurrentScintillaHandle(MyNppPlugin.NppData);
  if not IsWindow(LhWd) then
    Exit;
  LBytes := Npp_SciGetSelText(LhWd);
  if Length(LBytes) > 0 then
    Result := TEncoding.UTF8.GetString(LBytes);
end;

procedure AppendToCurrentNppText(AText: string);
var
  LStream: TStringStream;
begin
  LStream := TStringStream.Create(AText+#0, TEncoding.UTF8);
  try
   // Npp_FileNew(MyNppPlugin.NppHandle);
    Npp_SciAppedText(Npp_GetCurrentScintillaHandle(MyNppPlugin.NppData), LStream.Bytes);
  finally
    LStream.Free;
  end;
end;

procedure DbgS(fmt: string; Args: array of const);
begin
  OutputDebugString(PChar(Format(fmt, Args)));
end;

procedure DelphiConnstToGolang; cdecl;
var
  LStrs, LResult: TStringList;
  I: Integer;
  LLine, LTempStr: string;
begin
  // 新建的文件默认就是utf8
  LStrs := TStringList.Create;
  LResult := TStringList.Create;
  try
    LStrs.Text := GetCurrentNppText;
    for I := 0 to LStrs.Count - 1 do
    begin
      LLine := LStrs[I].Trim;
      if LLine.StartsWith('{$') then
        Continue;
      LResult.Add(LStrs[I]);
    end;
    LTempStr := LResult.Text.Replace('{', '/*')
                        .Replace('}', '*/')
                        .Replace('$', '0x')
                        .Replace(';', '');

    DbgS('%s', [LTempStr]);
    SetNewPageNppText(LTempStr);
  finally
    LResult.Free;
    LStrs.Free;
  end;
end;

procedure ShowPopupMenu; cdecl;
var
  LP: TPoint;
begin
  if Assigned(MyNppPlugin.FPm) then
  begin
    GetCursorPos(LP);
    MyNppPlugin.FPm.Popup(LP.X, LP.Y);
  end;
end;  


procedure WinApiTransparentToGo; cdecl;
type

 TParam = record
   Name: string;
   &Type: string;
   var_Const: string;
 end;

var
  LLine: string;

 function IsFunc: Boolean;
  begin
    Result := LLine.StartsWith('function', True);
  end;

  function IsProc: Boolean;
  begin
    Result := LLine.StartsWith('procedure', True);
  end;   

  function CopyFuncName: string;
  var
    LStartIndex, LP: Integer;
  begin
    Result := '';
    LStartIndex := -1;
    if IsFunc then
      LStartIndex := 8
    else if IsProc then
      LStartIndex := 9;
    if LStartIndex = -1 then
      Exit;
    LP := Pos('(', LLine, LStartIndex + 1);
    // 这种情况是没有参数的
    if LP = 0 then
      LP := Pos(';', LLine, LStartIndex + 1);
    if LP > 0 then
      Result := Trim(Copy(LLine, LStartIndex + 1, LP - LStartIndex - 1));
  end;

  function HaveParam: Boolean;
  begin
    Result := (LLine.IndexOf('(') > 0) and (LLine.IndexOf(')') > 0);
  end;

  function ParseParam: TArray<TParam>;
  var
    LParams: string;
    LStart: Integer;
    LSubPs, LSub, LSub3: TArray<string>;
    LItem: TParam;
    I: Integer;
  begin
    Result := nil;
    LStart := LLine.IndexOf('(');
    if LStart = -1 then
      Exit;
    LParams := Trim(LLine.Substring(LStart+1, LLine.IndexOf(')') - LStart - 1));
    if Length(LParams) > 0 then
    begin
      LSubPs := LParams.Split([';']);
      for I := 0 to High(LSubPs) do
      begin
        LItem.Name := '';
        LItem.&Type := '';
        LItem.var_Const := '';
        LSub := Trim(LSubPs[I]).Split([':']);
        if Length(LSub) >= 1 then
        begin
          Litem.Name := LSub[0].Trim;
          LSub3 := LItem.Name.Split([' ']);
          if Length(LSub3) >= 2 then
          begin
            LItem.Name := Trim(LSub3[1]);
            LItem.var_Const := Trim(LSub3[0]);
          end;
        end;
        if Length(LSub) >= 2 then
          Litem.&Type := LSub[1].Trim;
        SetLength(Result, Length(Result)+1);

        if LItem.Name <> '' then
        begin
          if CharInSet(LItem.Name[1], ['A'..'Z']) then
            LItem.Name[1] := LowerCase(LItem.Name[1])[1];
        end;  
        
        Result[High(Result)] := LItem;
      end;
    end;
  end;

  function GetReturnType: string;
  var
    LRetP: Integer;
  begin
    Result := '';
    if IsFunc then
    begin
      if HaveParam then
        LRetP := Pos(')', LLine)
      else LRetP := Pos(';', LLine);
      if LRetP = 0 then
        Exit;
      Result := Copy(LLine, LRetP + 1, Pos(';', LLine, LRetP + 1) - LRetP - 1);
      Result := Trim(Result.Replace(':', ''));
    end;  
  end;

  function GetDllName: string;
  var
    LP, LP2: Integer;
  begin
    Result := '';
    LP := Pos('external', LLine);
    if LP > 0 then
    begin
      Inc(LP, 8);
      LP2 := Pos('name', LLine, LP + 1);
      if LP2 > 0 then
        Result := Trim(Copy(LLine, LP + 1, LP2 - LP - 1));
      if not Result.StartsWith('''') then
        Result := Result.Replace('''', '') + 'dll' //补上一个
      else
        Result := Result.Replace('.', '');
      if Length(Result) > 0 then
       if CharInSet(Result[1], ['A'..'Z']) then
         Result[1] := LowerCase(Result[1])[1]
    end;
  end;

  function GetExportRealName: string;
  var 
    LP: Integer;
  begin
    Result := '';
    if Pos('external', LLine) > 0 then
    begin
      LP := LLine.LastIndexOf('name');
      if LP > 0 then
        Inc(LP, 5); 
      Result := Trim(LLine.Substring(LP, Length(LLine) - LP - 1));
      Result := Result.Replace('''', '');
    end;  
  end;    

  function GetGoCodeParam(AParams: TArray<TParam>): string;
  var
    LItem: TParam;
    I: Integer;
    LCVType: string;
  begin
    Result := '';
    if HaveParam then
    begin
      for I := 0 to High(AParams) do
      begin
        LItem := AParams[I];
        if I > 0 then
          Result := Result + ', ';
        LCVType := ConvType(LItem.&Type);
        Result := Result + LItem.Name + ' ';
        if (LItem.var_Const = 'var') or (LItem.var_Const = 'const') then
          Result := Result + '*';
        Result := Result + LCVType;
      end;
      Result := Trim(Result);
    end;
  end;  
  
var
  LStrs: TStringList;
  I, J: Integer;
  LFName, LRetType, LCvRetType, LCvPType: string;
  LImports, LCodeList: TStringList;
  LCodeBody: string;
  LItem: TParam;
  LParams: TArray<TParam>;
begin
  LStrs := TStringList.Create;  
  LImports := TStringList.Create;
  LCodeList := TStringList.Create;
  try
    LStrs.Text := GetCurrentNppText;
    for I := 0 to LStrs.Count - 1 do
    begin
      LLine := LStrs[I].Trim;
      if LLine.StartsWith('{') or LLine.StartsWith('//') or LLine.StartsWith('}') then
        Continue;
      LFName := CopyFuncName;
      if LFName = '' then
        Continue;
      DbgS('FuncName: %s', [LFName]);
   
      LRetType := GetReturnType;
      LCvRetType := ConvType(LRetType);
      
      LParams := ParseParam;
      
      LImports.Add(Format('_%s = %s.NewProc("%s")', [LFName, GetDllName, GetExportRealName]));

      LCodeBody := Format('func %s(%s) %s', [LFName, GetGoCodeParam(LParams), LCvRetType]);
      if LRetType <> '' then
        LCodeBody := LCodeBody + ' ';
      LCodeBody := LCodeBody + '{'#13#10;
      LCodeBody := LCodeBody + '    ';
      if LRetType <> '' then
        LCodeBody := LCodeBody + 'r, _, _ := ';
      LCodeBody := LCodeBody + '_' + LFName + '.Call(';
      for J := 0 to High(LParams) do
      begin  
        LItem := LParams[J]; 
        if J > 0 then
          LCodeBody := LCodeBody + ', ';
          
        LCvPType := ConvType(LItem.&Type);
        if LCvPType <> 'uintptr' then
        begin
          // pointer
          if LCvPType[1] = '*' then
            LCodeBody := LCodeBody + 'uintptr(unsafe.Pointer(' + LItem.Name + '))'
          else
          if LCvPType = 'string' then
            LCodeBody := LCodeBody + 'CStr(' + LItem.Name + ')'
          else if LCvPType = 'bool' then
            LCodeBody := LCodeBody + 'CBool(' + LItem.Name + ')'
          else LCodeBody := LCodeBody + 'uintptr(' + LItem.Name + ')';
        end
        else
          LCodeBody := LCodeBody + LItem.Name;
      end;
        
      LCodeBody := LCodeBody + ')'#13#10;
      if LRetType <> '' then
      begin
        LCodeBody := LCodeBody + '    return ';
        if LCvRetType <> 'uintptr' then
        begin
          if LCvRetType = 'bool' then
            LCodeBody := LCodeBody + 'r != 0'
          else if LCvRetType = 'string' then
            LCodeBody := LCodeBody + 'GoStr(r)'   
          else   
            LCodeBody := LCodeBody + LCvRetType + '(r)';
        end
        else LCodeBody := LCodeBody + 'r';
        LCodeBody := LCodeBody + #13#10;
      end;
      LCodeBody := LCodeBody + '}';

      LCodeList.Add(LCodeBody);
      LCodeList.Add('');
    end;
    {$IFDEF DEBUG}
      DbgS('Imports: %s', [LImports.Text]);
      DbgS('-------------code------------', []);
      DbgS('Code:%s', [LCodeList.Text]);
    {$ENDIF}
    SetNewPageNppText(LImports.Text + sLineBreak + LCodeList.Text);
  finally
    LCodeList.Free;
    LImports.Free;
    LStrs.Free;
  end;
end;


procedure DelphiRecordToGoStruct; cdecl;
var
  LStrs, LResult: TStringList;
  LLine: string;
  I, LP: Integer;
  LStrcutName: string;
  LArr: TArray<string>;
  LCVType: string;
  LFName, LFType: string;
  LArrLen: string;
  LIsArr: Boolean;
begin
  LStrs := TStringList.Create;
  try
    LResult := TStringList.Create;
    try
      LStrs.Text := GetCurrentNppText;
      I := 0;
      while I < LStrs.Count do
      begin
        LLine := Trim(LStrs[I]);
        if LLine.IndexOf('record') <> -1 then
        begin
          LStrcutName := Trim(LLine.Substring(0, LLine.IndexOf('=')));

          LResult.Add(Format('type %s struct {', [LStrcutName]));
          
          repeat
            Inc(I);
            
            LLine := Trim(LStrs[I]);
            LArr := LLine.Split([':']);
            if Length(LArr) >= 2 then
            begin
              LFName := Trim(LArr[0]);
              LFType := Trim(LArr[1].Replace(';', ''));
            
              if (LFName[1] = '_') then
                LFName := Copy(LFName, 2, Length(LFName) - 1);
              LFName[1] := UpCase(LFName[1]);

              LArrLen := '';
              // 是数组
              LIsArr := LFType.StartsWith('array', True);
              if LIsArr then
              begin
                // 静太数组
                LP := LFType.IndexOf('[');
                if LP > 0 then
                begin
                  LP := LFType.LastIndexOf('.');
                  if LP > 0 then
                  begin
                    Inc(LP);
                    LArrLen := LFType.Substring(LP, LFType.IndexOfAny([' ', '-', '+']) - LP);
                  end;
                end;
                LFType := Trim(LFType.Substring(LFType.LastIndexOf('of')+3));   
              end;  


              LCVType := ConvType(LFType);
              if LCVType = 'string' then
                LCVType := LFType;

              if LIsArr then
              begin
                // 静态数组
                if LArrLen <> '' then
                  LResult.Add(Format('    %s [%s]%s', [LFName, LArrLen, LCVType]))
                else
                  LResult.Add(Format('    %s []%s', [LFName, LCVType]));
              end else
                LResult.Add(Format('    %s %s', [LFName, LCVType]));
            end;
          until LLine.StartsWith('end', True);

          LResult.Add('}');
          LResult.Add('');
        end; 
        Inc(I);
      end;
      SetNewPageNppText(LResult.Text);  
    finally
      LResult.Free;
    end;
  finally
    LStrs.Free;
  end;
end;

procedure DelphiEnumToGo; cdecl;
var
  LResult: TStringList;
  LText, LLine: string;
  LP1, LP2, I: Integer;
  LName, LBody: string;
begin
  LText := GetCurrentNppText;
  if LText = '' then
    Exit;
  LResult := TStringList.Create;
  try
    LName := '';
    LP1 := Pos('=',  LText);
    if LP1 > 0 then
      LName := Trim(Copy(LText, 1, LP1-1));
    if LName = '' then
      Exit;
    LP1 := Pos('(', LText);
    if LP1 > 0 then
    begin
      LP2 := Pos(')', LText, LP1);
      if LP2 > 0 then
      begin
        LBody := Trim(Copy(LText, LP1 + 1, LP2 - LP1 - 1));
        LBody := LBody.Replace(',', sLineBreak);
        LResult.Text := LBody;
        for I := LResult.Count - 1 downto 0 do
        begin
          LLine := LResult[I].Trim;
          if LLine = '' then
          begin
            LResult.Delete(I);
            Continue;
          end;

          LLine[1] := UpCase(LLine[1]);

         // DbgS('Line:%s', [LLine]);

          LLine := '    ' + LLine;
          if I = 0 then
            LResult[I] := LLine + ' = iota + 0'
          else
            LResult[I] := LLine;
        end;
        LText := 'type ' + LName + ' int32' + sLineBreak + sLineBreak;
        LText := LText + 'const (' + sLineBreak;
        LText := LText + LResult.Text;
        LText := LText + ')' + sLineBreak;
        SetNewPageNppText(LText);
      end;
    end;
  finally
    LResult.Free;
  end;
end;

procedure TrimSpaceAndAddDoubleQuotes; cdecl;
var
  LStr, LResult: TStringList;
  I: Integer;
  LLine: string;
begin
  LStr := TStringList.Create;
  LResult := TStringList.Create;
  try
    LStr.Text := GetCurrentNppText;
    for I := 0 to LStr.Count - 1 do
    begin
      LLine := Trim(LStr[I]);
      if LLine = '' then
        Continue;
      LResult.Add('"' + LLine + '"');
    end;
    SetNewPageNppText(LResult.Text);
  finally
    LResult.Free;
    LStr.Free;
  end;
end;

procedure TrimSpaceAndAddSingleQuotes; cdecl;
var
  LStr, LResult: TStringList;
  I: Integer;
  LLine: string;
begin
  LStr := TStringList.Create;
  LResult := TStringList.Create;
  try
    LStr.Text := GetCurrentNppText;
    for I := 0 to LStr.Count - 1 do
    begin
      LLine := Trim(LStr[I]);
      if LLine = '' then
        Continue;
      LResult.Add('''' + LLine + '''');
    end;
    SetNewPageNppText(LResult.Text);
  finally
    LResult.Free;
    LStr.Free;
  end;
end;


procedure StringProcess; cdecl;
var
  LCurText: string;
begin
  LCurText := GetCurrentNppText;
  if ShowConvOptions(LCurText) then
    SetNewPageNppText(LCurText);
end;


procedure GoogleTransparent; cdecl;
var
//  HttpReq: IXMLHTTPRequest;
  LGetURL: string;
  LText, LRet: string;
  LJson: TJSONValue;
begin
  LText := GetCurrentNppSelectText;
  if LText = '' then
    Exit;
  LGetURL := TIdURI.URLEncode(Format('https://translate.google.cn/translate_a/single?client=webapp' +
                    '&sl=zh-CN&tl=en&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt' +
                    '=rw&dt=rm&dt=ss&dt=t&source=bh&ssel=0&tsel=0&kc=1&tk=745385.909105&' +
                    'q=%s', [LText]));



  try
    OutputDebugString(PChar('URL:' + LGetURL));
     with THttpSession.Create do
     begin
       try
         LJson := TJSONObject.ParseJSONValue(GetText(LGetURL, []));
         if Assigned(LJson) then
         begin
           OutputDebugString(PChar(LJson.ToString));
           try
  //           if LJson.TryGetValue<string>('[0].[0].[0].[0]', LRet) then
  //           begin
  //             AppendToCurrentNppText(LRet);
  //           end;
           finally
             LJson.Free;
           end;
         end;
       finally
         Free;
       end;
     end;

//    HttpReq.setRequestHeader('User-Agent', '');
//    HttpReq.setRequestHeader('If-Modified-Since', '0');
//    HttpReq.setRequestHeader('Accept', 'application/json');
//    HttpReq.setRequestHeader('Content-Type', 'application/json');
//    HttpReq.setRequestHeader('Charset', 'utf-8');
//    HttpReq.setRequestHeader('Referer', 'https://translate.google.cn/m/translate?hl=zh-CN');
//    HttpReq.send(EmptyStr);

//    AppendToCurrentNppText(HttpReq.ResponseBody);
  except
     on E:Exception do
       OutputDebugString(PChar('GoogleTransparent Error:' + E.message));
  end;
//  HttpReq := nil;

  // https://translate.google.cn/translate_a/single?client=webapp&sl=zh-CN&tl=en&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&source=bh&ssel=0&tsel=0&kc=1&tk=745385.909105&q=%E9%A1%B9%E7%9B%AE%E6%80%BB%E6%95%B0
  // https://translate.google.cn/translate_a/single
  //  client=webapp
  //  sl=zh-CN
  //  hl=zh-CN
  //  dt=at
end;


{ TNppPluginEx }

constructor TNppPluginEx.Create;
begin
  inherited;
  PluginName := '我的一些处理工具';
  FPm := TPopupMenu.Create(nil);
end;

destructor TNppPluginEx.Destroy;
begin
  FPm.Free;
  inherited;
end;

procedure TNppPluginEx.OnMenuItemClick(Sender: TObject);
var
  LProc: procedure; cdecl;
begin
  @LProc := Pointer(TMenuItem(Sender).Tag);
  if Assigned(@LProc) then
    LProc();
end;

procedure TNppPluginEx.commandMenuInit;
begin
  inherited;
  AddNewMenu('Delphi常量转Go', @DelphiConnstToGolang);
  AddNewMenu('Delphi Winapi翻译至Go', @WinApiTransparentToGo);
  AddNewMenu('Delphi结构转Go', @DelphiRecordToGoStruct);
  AddNewMenu('Delphi枚举转Go', @DelphiEnumToGo);
  AddNppPluginFunc('---', nil);
//  AddNewMenu('移除空行-删首尾空-添加双引号', @TrimSpaceAndAddDoubleQuotes);
//  AddNewMenu('移除空行-删首尾空-添加单引号', @TrimSpaceAndAddSingleQuotes);
  AddNewMenu('字符串处理', @StringProcess);
  AddNppPluginFunc('----', nil);
  AddNppPluginFunc('Delphi转Go工具集合', @ShowPopupMenu);
  AddNewMenu('Google翻译选择文本并附加结果', @GoogleTransparent);
end;


procedure TNppPluginEx.AddNewMenu(ACaption: string; AFunc: Pointer);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(FPm);
  LItem.Caption := ACaption;
  LItem.Tag := NativeInt(AFunc);
  LItem.OnClick := OnMenuItemClick;
  FPm.Items.Add(LItem);
  AddNppPluginFunc(PTCHAR(ACaption), AFunc);
end;

procedure TNppPluginEx.beNotified(var notifyCode: TSCNotification);
begin
  inherited;
  case notifyCode._nmhdr.code of
    SCN_CHARADDED :;
    NPPN_TBMODIFICATION :
      begin
        AddToolBtnOf(ShowPopupMenu, 'TOOL_SHOWDOCK');
      end;
  end;
end;

procedure InitConvTypeList;
begin
  with uTypeConvList do
  begin
    Add('BOOL', 'bool');
    Add('Boolean', 'bool');
    Add('Integer', 'int32');
    Add('Cardinal', 'uint32');
    Add('DWORD', 'uint32');
    Add('Pointer', 'uintptr');
    Add('UINT', 'uint32');
    Add('UIntPtr', 'uintptr');
    Add('Longint', 'uint32');
    Add('THandle', 'uintptr');
    Add('Word', 'uint16');
    Add('Byte', 'uint8');
    Add('LPCWSTR', 'string');
    Add('COLORREF', 'uint32');
    Add('LPARAM', 'uintptr');
    Add('WPARAM', 'uintptr');
    Add('NativeInt', 'int');
    Add('NativeUInt', 'uint');
    Add('HINST', 'uintptr');
//    Add('Int64', 'int64');
//    Add('UInt64', 'uint64');

    
    Add('PRect', '*TRect');
    Add('PPoint', '*Point');
    Add('PInteger', '*int32');
    Add('PDWORD', '*uint32');
    Add('PUINT_PTR', '*uintptr');
    
  end;
end;  

initialization
  MyNppPlugin := TNppPluginEx.Create;
  uTypeConvList := TDictionary<string, string>.Create;
  InitConvTypeList;

finalization
   uTypeConvList.Free;
   MyNppPlugin.Free;
  

end.

