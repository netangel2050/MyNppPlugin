{***************************************************************************}
{                                                                           }
{       功能：NppDock对话框                                                 }
{       名称：NppDockDialog.pas                                             }
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
{             当创建一个新的Form时把 xxx = class(TForm) 替换为              }
{             xxx = class(TNppDockDialog) 即可，其他暂时不需要              }
{             更改什么                                                      }
{                                                                           }
{             关于TPageControl如果要使用建议使用 TabControl代替，而且不能放 }
{             Panel之类的父容器，不然会在鼠标托动Dock的窗口至Float时Memo、  }
{             ListBox会不能刷新！当然如果你不介意的话无所谓了可以忽略！至于 }
{             这个原因是什么我也不清楚，用SPY++查看消息也没发现什么特别之处 }
{             如果你解决了这个问题记得发邮件给我，我也好知道到底为什么会这样}
{             倒是这个问题试过很多方法了都不行，头大！                      }
{                                                                           }
{***************************************************************************}

unit NppDockDialog;

{$I Notpad_Plugin.inc}

interface

uses
  Windows, Messages, Classes, SysUtils, Controls, Forms, NppPluginInc;

type
  TNppDockDialog = class(TForm)
  private
    FParent: HWND;
    FDockData: TtTbData;
    FCmdId: ULONG;
    FDockEvent : TNotifyEvent;
    FFloatEvent: TNotifyEvent;
  private
    function  GetSelfModuleFileName:PTCHAR;
    procedure RegisterDockDialog(DlgId: Integer; PluginName: PTCHAR; Poistion: Integer);
    // 参考网上代码,忘了哪个地方的出处了,总之感谢那位老大的方法
    procedure RemoveSelfControlParent;
    procedure UpdateDockDialog;
    procedure FDocking(Sender: TObject);
    procedure FFloating(Sender: TObject);
  public
    constructor Create(hParent: HWND; PluginName: PTCHAR; DlgId: Integer; Poistion: Cardinal = DWS_DF_CONT_BOTTOM);reintroduce;overload;
    destructor Destroy; override;
    procedure SetAdditionalInfo(AText: PTCHAR);
//    procedure Show;
//    procedure Hide;
  public
    property CmdID: ULONG read FCmdId write FCmdId;
  protected
    procedure WMNotify(var MSG: TWMNotify);message WM_NOTIFY;
    procedure DoShow;override;
    procedure DoHide;override;
  published
    property OnDock : TNotifyEvent read FDockEvent write FDockEvent;
    property OnFloat: TNotifyEvent read FFloatEvent write FFloatEvent;
  end;

implementation

uses NppMacro;

{ TNppDockDialog }

constructor TNppDockDialog.Create(hParent: HWND; PluginName: PTCHAR; DlgId: Integer; Poistion: Cardinal);
begin
  // 这里不 Create(nil)而是Create(Application)这样做可以让插件卸载时自动释放
  // 而无需调用 xxx.Free，当然你也可以在 pluginCleanUp 函数中写入一句释放
  inherited Create(Application);
  FParent     := hParent;
  BorderStyle := bsSizeToolWin;
  FCmdId := 0;

  FillChar(FDockData, SizeOf(FDockData), 0);
  GetMem(FDockData.pszAddInfo, MAX_PATH);
  
  Npp_DockDialogAdd(FParent, Handle);
  // RemoveSelfControlParent这个函数很重要，必须执行，否则当有的控件
  // 拥有 csAcceptsControls 属性时会造成 Notepad++崩溃
  RemoveSelfControlParent;
  RegisterDockDialog(DlgId, PluginName, Poistion);
end;

destructor TNppDockDialog.Destroy;
begin
  {$IFDEF UNICODE}
    {$IFDEF DELPHI7}
      if Assigned(FDockData.pszModuleName) then FreeMem(FDockData.pszModuleName);
    {$ENDIF}
  {$ENDIF}
  if Assigned(FDockData.pszAddInfo) then FreeMem(FDockData.pszAddInfo);
  Npp_DockDialogRemove(FParent, Handle);
  inherited;
end;

function TNppDockDialog.GetSelfModuleFileName: PTCHAR;
var
  ModuleName:string;
begin
   ModuleName := GetModuleName(HInstance);
{$IFDEF UNICODE}
   {$IFDEF DELPHI7}
     GetMem(Result, MAX_PATH);
     StringToWideChar(ExtractFileName(ModuleName), Result, Length(ModuleName));
   {$ELSE}
     Result := PTCHAR(ExtractFileName(ModuleName));
   {$ENDIF}
{$ELSE}
   Result := PTCHAR(ExtractFileName(ModuleName));
{$ENDIF}
end;

procedure TNppDockDialog.RegisterDockDialog(DlgId: Integer; PluginName: PTCHAR; Poistion: Integer);
begin
  FDockData.uMask   := Poistion or DWS_ADDINFO;
  FDockData.pszModuleName := GetSelfModuleFileName;
  FDockData.dlgID   := DlgId;
  FDockData.hClient := Handle;
  FDockData.pszName := PluginName;
  Npp_DockDialogRegister(FParent, FDockData);
end;

procedure TNppDockDialog.UpdateDockDialog;
begin
  Npp_DockDialogUpdateDisplay(FParent, Handle);
end;

procedure TNppDockDialog.WMNotify(var MSG: TWMNotify);
var
  Code: Integer;
begin
  if MSG.NMHdr.hwndFrom = FParent then
  begin
     Code := MSG.NMHdr.code and $FFFF;
     case Code of
        DMN_CLOSE :
          begin
            Self.Hide;
            if not IsWindowVisible(FParent) then ShowWindow(FParent, SW_SHOW);
          end;
        DMN_FLOAT : FFloating(Self);
        DMN_DOCK  : FDocking(Self);
     end;
  end;
  inherited;
end;

procedure TNppDockDialog.DoHide;
begin
  Npp_DockDialogHide(FParent, Handle);
  inherited;
end;

procedure TNppDockDialog.DoShow;
begin
  Npp_DockDialogShow(FParent, Handle);
  inherited;
end;

procedure TNppDockDialog.RemoveSelfControlParent;
var
  I: Integer;
  WinCtl: TWinControl;
  CtlObj: TControl;
  Style: Integer;
begin
  for I := Self.ComponentCount - 1 downto 0 do
  begin
    if Self.Components[I] is TControl then
    begin
      CtlObj := Self.Components[I] as TControl;
      if CtlObj is TWinControl then
      begin
        WinCtl := CtlObj as TWinControl;
        WinCtl.HandleNeeded;
        Style := GetWindowLong(WinCtl.Handle, GWL_EXSTYLE);
        if (Style and WS_EX_CONTROLPARENT = WS_EX_CONTROLPARENT) then
        begin
          Style := Style and not WS_EX_CONTROLPARENT;
          SetWindowLong(WinCtl.Handle, GWL_EXSTYLE, Style);
        end;
      end;
    end;
  end;
end;

procedure TNppDockDialog.SetAdditionalInfo(AText: PTCHAR);
begin
  _lstrcpy(FDockData.pszAddInfo, AText);
  UpdateDockDialog;
end;

procedure TNppDockDialog.FDocking(Sender: TObject);
begin
  if Assigned(FFloatEvent) then
    FFloatEvent(Sender);
end;

procedure TNppDockDialog.FFloating(Sender: TObject);
begin
  if Assigned(FDockEvent) then
   FDockEvent(Sender);
end;


end.
