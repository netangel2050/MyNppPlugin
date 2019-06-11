{***************************************************************************}
{                                                                           }
{       功能：Scintilla类封装                                               }
{       名称：ScintillaClass.pas                                                 }
{       版本：1.0                                                           }
{       环境：Win7 Sp1 32bit                                                }
{       工具：Delphi 7                                                      }
{       日期：2013/5/30 13:38:34                                             }
{       作者：ying32                                                        }
{       QQ  ：396506155                                                     }
{       MSN ：ying_32@live.cn                                               }
{       E-mail：yuanfen3287@vip.qq.com                                      }
{       Website：http://www.ying32.tk                                       }
{       版权所有 (C) 2013-2013 ying32.tk All Rights Reserved                }
{                                                                           }
{***************************************************************************}
unit ScintillaClass;

{$I Notpad_Plugin.inc}

interface

uses
  Windows, SysUtils, NppMacro, NppPluginInc;

{ TScintilla }
type
  TScintilla = class
  private
    FNppData: TNppData;
    FSciHandle: HWND;
  private
    procedure SetCurSci;
    function  GetCurSciHandle: HWND;
    function  GetLength: Integer;
    function  GetLine: Integer;
    procedure SetGoToLine(Lines: Integer);
    procedure SetZoomLevel(Level: Integer);
    function  GetZoomLevel: Integer;
    procedure SetGoToPos(Posi: Integer);
    function  GetPos: Integer;
    procedure SetText(const Text: string);
    function  GetText:string;
  public
    constructor Create(NppData: TNppData);overload;
    destructor Destroy;override;
    procedure ReplaceSel(const Text: string);
    procedure AppedText(const Text: string);
    procedure EnSureVisible(Lines: Integer);
  public
    property Handle : HWND read GetCurSciHandle;
    property Length : Integer read GetLength;
    property Lines  : Integer read GetLine write SetGoToLine;
    property ZoomLevel: Integer read GetZoomLevel write SetZoomLevel;
    property Position : Integer read GetPos write SetGoToPos;
    property Text: string read GetText write SetText;
  end;  
 

implementation

{ TScintilla }

constructor TScintilla.Create(NppData: TNppData);
begin
  inherited Create;
  FNppData := NppData;
end;

destructor TScintilla.Destroy;
begin
  inherited;
end;

procedure TScintilla.AppedText(const Text: string);
begin
  SetCurSci;
  Npp_SciAppedText(FSciHandle, Text);
end;

procedure TScintilla.EnSureVisible(Lines: Integer);
begin
  SetCurSci;
  Npp_SciEnSureVisible(FSciHandle, Lines);
end;

function TScintilla.GetLength: Integer;
begin
  SetCurSci;
  Result := Npp_SciGetLength(FSciHandle);
end;

function TScintilla.GetLine: Integer;
begin
  SetCurSci;
  Result := Npp_SciGetLine(FSciHandle);
end;

function TScintilla.GetZoomLevel: Integer;
begin
  SetCurSci;
  Result := Npp_SciGetZoomLevel(FSciHandle);
end;

procedure TScintilla.SetGoToLine(Lines: Integer);
begin
  SetCurSci;
  Npp_SciGoToLine(FSciHandle, Lines);
end;

procedure TScintilla.SetGoToPos(Posi: Integer);
begin
  SetCurSci;
  Npp_SciGoToPos(FSciHandle, Posi);
end;

procedure TScintilla.ReplaceSel(const Text: string);
begin
  SetCurSci;
  Npp_SciReplaceSel(FSciHandle, Text);
end;

procedure TScintilla.SetText(const Text: string);
begin
  SetCurSci;
  Npp_SciSetText(FSciHandle, Text);
end;

function TScintilla.GetText:string;
begin
  SetCurSci;
  Result := Npp_SciGetText(FSciHandle);
end;  

procedure TScintilla.SetZoomLevel(Level: Integer);
begin
  SetCurSci;
  Npp_SciSetZoomLevel(FSciHandle, Level);
end;

function TScintilla.GetPos: Integer;
begin
  SetCurSci;
  Result := 0;//Npp_Sci_
end;

procedure TScintilla.SetCurSci;
begin
  FSciHandle := Npp_GetCurrentScintillaHandle(FNppData);
end;

function TScintilla.GetCurSciHandle: HWND;
begin
  SetCurSci;
  Result := FSciHandle;
end;  



end.