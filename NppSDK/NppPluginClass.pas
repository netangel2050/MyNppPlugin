{***************************************************************************}
{                                                                           }
{       功能：插件函数实现过程                                              }
{       名称：NppPlugin.pas                                                 }
{       版本：1.0                                                           }
{       环境：Win7 Sp1 32bit                                                }
{       工具：Delphi 7                                                      }
{       日期：2013/4/20 14:06:26                                            }
{       作者：ying32                                                        }
{       QQ  ：396506155                                                     }
{       MSN ：ying_32@live.cn                                               }
{       E-mail：yuanfen3287@vip.qq.com                                      }
{       Website：http://www.ying32.tk                                       }
{       版权所有 (C) 2013-2013 ying32.tk All Rights Reserved                }
{                                                                           }
{---------------------------------------------------------------------------}
{                                                                           }
{       备注：                                                              }
{                                                                           }
{                                                                           }
{                                                                           }
{***************************************************************************}

unit NppPluginClass;

interface

uses
  Windows, Messages, Forms, NppPluginInc, SysUtils, Scintilla;

type
  TNppPlugin = class(TObject)
  private
    FNppPluginName: PTCHAR;
    FNppPluginFuncItem: array of TFuncItem;
    FNppPluginFuncCount: Integer;
    FNppData: TNppData;
    FAppHandle: THandle;
  private
    function  GetNppPluginFuncCount: Integer;
    function  GetNppPluginFuncAddr: Pointer;
    function  GetNppHandle: HWND;
    procedure SetLangType(Value: TLangType);
    function  GetLangType: TLangType;
    function  GetConfigDir: string;
    function  GetFileName: string;
    function  GetFileDir: string;
    function  GetShortFileName: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure pluginInit;virtual;
    procedure pluginCleanUp;virtual;
    procedure commandMenuInit;virtual;
    procedure commandMenuCleanUp;virtual;
    procedure AddNppPluginFunc(CmdName: PTCHAR; pFunc: PFUNCPLUGINCMD; sk: PShortcutKey = nil; Check0nInit: Boolean = False);
    procedure beNotified(var notifyCode: TSCNotification);virtual;
    procedure AddToolBtnOf(CmdId: ULONG; ResName: PAnsiChar);overload;
    procedure AddToolBtnOf(pFunc: PFUNCPLUGINCMD; ResName: PAnsiChar);overload;
    procedure MessageProc(var Msg: TMessage);virtual;
    function  GetCmdId(Index: Integer):ULONG;
    function  GetIdByFunc(pFunc: PFUNCPLUGINCMD): ULONG;
    function  GetCmdIdByFunc(pFunc: PFUNCPLUGINCMD): ULONG;
    function  ShortKey(AKey: Byte; ACtrl: Boolean = False; AAlt: Boolean = False; AShift: Boolean = False): PShortcutKey;


    procedure SaveFile;
    procedure OpenFile;
    procedure FileNew;
  public
    property PluginName: PTCHAR read FNppPluginName write FNppPluginName;
    property PluginFuncAddr : Pointer read GetNppPluginFuncAddr;
    property PluginFuncCount: Integer read GetNppPluginFuncCount;
    property NppData: TNppData read FNppData write FNppData;
    property NppHandle: HWND read GetNppHandle;
    property LangType: TLangType read GetLangType write SetLangType;
    property ConfigDir: string read GetConfigDir;
    property FileName: string read GetFileName;
    property FileDir: string read GetFileDir;
    property ShortFileName: string read GetShortFileName;
  end;


implementation

uses NppMacro;

{ TNppPlugin }

constructor TNppPlugin.Create;
begin
  inherited;
  FNppPluginFuncCount := 0;
  FNppPluginName := nil;
  SetLength(FNppPluginFuncItem, 0);
end;

destructor TNppPlugin.Destroy;
var
  I: Integer;
begin
  for I := 0 to High(FNppPluginFuncItem) do
   if FNppPluginFuncItem[I]._pShKey <> nil then
     Dispose(FNppPluginFuncItem[I]._pShKey);
  SetLength(FNppPluginFuncItem, 0);
  inherited;
end;

procedure TNppPlugin.AddNppPluginFunc(CmdName: PTCHAR; pFunc: PFUNCPLUGINCMD; sk: PShortcutKey; Check0nInit: Boolean);
begin
  Inc(FNppPluginFuncCount);
  SetLength(FNppPluginFuncItem, FNppPluginFuncCount);

  if not Assigned(pFunc) then Exit;

  _lstrcpy(FNppPluginFuncItem[FNppPluginFuncCount - 1]._itemName, CmdName);
  FNppPluginFuncItem[FNppPluginFuncCount - 1]._pFunc      := pFunc;
  FNppPluginFuncItem[FNppPluginFuncCount - 1]._init2Check := Check0nInit;
  FNppPluginFuncItem[FNppPluginFuncCount - 1]._pShKey     := sk;
end;

function TNppPlugin.GetNppPluginFuncAddr: Pointer;
begin
  Result := @FNppPluginFuncItem[0]; { Result := FNppPluginFuncItem }
end;

function TNppPlugin.GetNppPluginFuncCount: Integer;
begin
  Result := Length(FNppPluginFuncItem);
end;

procedure TNppPlugin.beNotified(var notifyCode: TSCNotification);
begin
  case notifyCode._nmhdr.code of
     NPPN_SHUTDOWN : commandMenuCleanUp;
     NPPN_BUFFERACTIVATED :
      begin
//        if notifyCode._nmhdr.hwndFrom = FNppData._nppHandle then
//        begin
//          case Npp_GetCurrentLangType(FNppData._nppHandle) of
//            L_BATCH : ;
//            L_CPP, L_C : ;
//          end;
//          //OutputDebugString(PChar(TLangTypeStr[Npp_GetCurrentLangType(FNppData._nppHandle)]));
//          //OutputDebugString(PChar(IntToStr(notifyCode._nmhdr.idFrom)));
//        end;
      end;
  end;
end;

function TNppPlugin.GetCmdId(Index: Integer): ULONG;
begin
  if (Index >= 0) and (Index < FNppPluginFuncCount) then
    Result := FNppPluginFuncItem[Index]._cmdID
  else Result := Cardinal(-1);
end;
// 通过函数地址获取当前函数在数组中的位置，这样就证了
// 当需要改动插件函数位置时不需要再去调整函数的位置了
function TNppPlugin.GetIdByFunc(pFunc: PFUNCPLUGINCMD): ULONG;
var
  I: Integer;
begin
  Result := Cardinal(-1);
  for I := 0 to High(FNppPluginFuncItem) do
  begin
    if @FNppPluginFuncItem[I]._pFunc = @pFunc then
    begin
      Result := I;
      Break;
    end;  
  end;
end;

function TNppPlugin.GetCmdIdByFunc(pFunc: PFUNCPLUGINCMD): ULONG;
begin
  Result := GetCmdId(GetIdByFunc(pFunc));
end;


procedure TNppPlugin.AddToolBtnOf(CmdId: ULONG; ResName: PAnsiChar);
 var
  ToolBar: TToolbarIcons;
begin
  // 关于 ToolBarIcons.hToolbarBmp
  // 如果想要透明的话必须使用8位色彩的BMP图像且同时指明LoadImage中的
  // Flags为LR_LOADMAP3DCOLORS
  // 背景色设置为 RGB(192,192,192)或者可替换的
  // 可以使用PhotoShop对所需要的位图进行处理
  ToolBar.hToolbarBmp  := LoadImageA(HInstance, ResName, IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE or LR_LOADMAP3DCOLORS);
  ToolBar.hToolbarIcon := 0;
  Npp_AddToolBarIcon(FNppData._nppHandle, CmdId, ToolBar);
end;

procedure TNppPlugin.AddToolBtnOf(pFunc: PFUNCPLUGINCMD; ResName: PAnsiChar);
begin
  AddToolBtnOf(GetCmdIdByFunc(pFunc), ResName);
end;

function TNppPlugin.GetNppHandle: HWND;
begin
  Result := FNppData._nppHandle;
end;

function TNppPlugin.ShortKey(AKey: Byte; ACtrl: Boolean; AAlt: Boolean; AShift: Boolean): PShortcutKey;
begin
  New(Result);
  Result._isCtrl  := ACtrl;
  Result._isAlt   := AAlt;
  Result._isShift := AShift;
  Result._key     := AKey;
end;

procedure TNppPlugin.MessageProc(var Msg: TMessage);
begin
 Dispatch(Msg);
end;

procedure TNppPlugin.commandMenuInit;
begin
  FAppHandle := Application.Handle;
  Application.Handle := GetNppHandle;
end;

procedure TNppPlugin.commandMenuCleanUp;
begin
  Application.Handle := FAppHandle;
end;

procedure TNppPlugin.pluginCleanUp;
begin
end;

procedure TNppPlugin.pluginInit;
begin
end;

function TNppPlugin.GetLangType: TLangType;
begin
  Result := Npp_GetCurrentLangType(GetNppHandle);
end;

procedure TNppPlugin.SetLangType(Value: TLangType);
begin
  Npp_SetCurrentLangType(GetNppHandle, Value);
end;

function TNppPlugin.GetConfigDir: string;
begin
  Result := Npp_GetPluginsConfigDir(GetNppHandle);
end;

function TNppPlugin.GetFileName: string;
begin
  Result := Npp_GetCurrentFileName(GetNppHandle);
end;

function TNppPlugin.GetFileDir: string;
begin
  Result := Npp_GetCurrentFileDir(GetNppHandle);
end;

function TNppPlugin.GetShortFileName: string;
begin
  Result := Npp_GetCurrentShortFileName(GetNppHandle);
end;

procedure TNppPlugin.SaveFile;
begin
  Npp_FileSave(GetNppHandle);
end;

procedure TNppPlugin.FileNew;
begin
  Npp_FileNew(GetNppHandle);
end;

procedure TNppPlugin.OpenFile;
begin
  Npp_FileOpen(GetNppHandle);
end;

end.
