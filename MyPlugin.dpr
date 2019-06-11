library MyPlugin;

{$I Notpad_Plugin.inc}

uses
  Windows,
  Vcl.Forms,
  NppPluginInc,
  NppPluginClass,
  Scintilla,
  PluginDefinition in 'PluginDefinition.pas',
  uConvOptions in 'uConvOptions.pas' {frmConvOptions},
  HttpSession in 'HttpSession.pas';

procedure setInfo(notpadPlusData: TNppData);cdecl;
begin
   MyNppPlugin.NppData := notpadPlusData;
   MyNppPlugin.commandMenuInit;
   Application.Handle := notpadPlusData._nppHandle;
   Application.Icon.Handle := LoadIcon(GetModuleHandle(nil), PChar(100));
end;

function getName: PTCHAR; cdecl;
begin
  Result := MyNppPlugin.PluginName;
end;

function getFuncsArray(var nbF: Integer):PFuncItem;cdecl;
begin
  nbF := MyNppPlugin.PluginFuncCount;
  Result := MyNppPlugin.PluginFuncAddr;
end;

procedure beNotified(var notifyCode: TSCNotification);cdecl;
begin
  MyNppPlugin.beNotified(notifyCode);
end;

function messageProc(iMessage: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;cdecl;
begin
  Result := 1;
end;

function isUnicode: BOOL;cdecl;
begin
  Result := True;
end;

procedure DllNewProc(dwReason: Cardinal);
begin
  case dwReason of
    DLL_PROCESS_ATTACH: ;
    DLL_PROCESS_DETACH: ;
    DLL_THREAD_ATTACH :;
    DLL_THREAD_DETACH :; 
  end;
end;  

exports
  setInfo,
  getName,
  getFuncsArray,
  beNotified,
  messageProc,
  isUnicode;


{$R *.res}
{$R .\Res\ExternalRes.res}
begin
  DLLProc := @DllNewProc;
  DllNewProc(DLL_PROCESS_ATTACH);
end.
