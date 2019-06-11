{***************************************************************************}
{                                                                           }
{       ���ܣ�NppDock�Ի���                                                 }
{       ���ƣ�NppDockDialog.pas                                             }
{       �汾��1.0                                                           }
{       ������Win7 Sp1 32bit                                                }
{       ���ߣ�Delphi 7                                                      }
{       ���ڣ�2013/4/20 14:06:26                                            }
{       ���ߣ�ying32                                                        }
{       QQ  ��396506155                                                     }
{       MSN ��ying_32@live.cn                                               }
{       E-mail��yuanfen3287@vip.qq.com                                      }
{       Website��http://www.ying32.tk                                       }
{       ��Ȩ���� (C) 2013-2013 ying32.tk All Rights Reserved                }
{                                                                           }
{---------------------------------------------------------------------------}
{                                                                           }
{       ��ע��                                                              }
{             ������һ���µ�Formʱ�� xxx = class(TForm) �滻Ϊ              }
{             xxx = class(TNppDockDialog) ���ɣ�������ʱ����Ҫ              }
{             ����ʲô                                                      }
{                                                                           }
{             ����TPageControl���Ҫʹ�ý���ʹ�� TabControl���棬���Ҳ��ܷ� }
{             Panel֮��ĸ���������Ȼ��������ж�Dock�Ĵ�����FloatʱMemo��  }
{             ListBox�᲻��ˢ�£���Ȼ����㲻����Ļ�����ν�˿��Ժ��ԣ����� }
{             ���ԭ����ʲô��Ҳ���������SPY++�鿴��ϢҲû����ʲô�ر�֮�� }
{             ����������������ǵ÷��ʼ����ң���Ҳ��֪������Ϊʲô������}
{             ������������Թ��ܶ෽���˶����У�ͷ��                      }
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
    // �ο����ϴ���,�����ĸ��ط��ĳ�����,��֮��л��λ�ϴ�ķ���
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
  // ���ﲻ Create(nil)����Create(Application)�����������ò��ж��ʱ�Զ��ͷ�
  // ��������� xxx.Free����Ȼ��Ҳ������ pluginCleanUp ������д��һ���ͷ�
  inherited Create(Application);
  FParent     := hParent;
  BorderStyle := bsSizeToolWin;
  FCmdId := 0;

  FillChar(FDockData, SizeOf(FDockData), 0);
  GetMem(FDockData.pszAddInfo, MAX_PATH);
  
  Npp_DockDialogAdd(FParent, Handle);
  // RemoveSelfControlParent�����������Ҫ������ִ�У������еĿؼ�
  // ӵ�� csAcceptsControls ����ʱ����� Notepad++����
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
