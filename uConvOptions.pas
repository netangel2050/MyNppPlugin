unit uConvOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmConvOptions = class(TForm)
    GroupBox1: TGroupBox;
    chkRemoveSpaceLine: TCheckBox;
    rgAddQuotes: TRadioGroup;
    chkTrimSpace: TCheckBox;
    chkAddCommaOnTail: TCheckBox;
    chkAddQuote: TCheckBox;
    Panel1: TPanel;
    Button1: TButton;
  private
    FSrcData: string;
    procedure PrcessText;
  public
    { Public declarations }
  end;

var
  frmConvOptions: TfrmConvOptions;

  function ShowConvOptions(var ACurText: string): Boolean;
implementation

{$R *.dfm}


function ShowConvOptions(var ACurText: string): Boolean;
begin
  frmConvOptions := TfrmConvOptions.Create(nil);
  try
    frmConvOptions.FSrcData := ACurText;
    Result := frmConvOptions.ShowModal = mrOk;
    if Result then
    begin
      frmConvOptions.PrcessText;
      ACurText := frmConvOptions.FSrcData;
    end;
  finally
    FreeAndNil(frmConvOptions);
  end;
end;

{ TfrmConvOptions }

procedure TfrmConvOptions.PrcessText;
var
  LStrs, LResult: TStringList;
  S: string;
  I: Integer;
begin
  LStrs := TStringList.Create;
  try
    LResult := TStringList.Create;
    try
      LStrs.Text := FSrcData;
      for I := 0 to LStrs.Count - 1 do
      begin
        S := LStrs[I];
        if chkRemoveSpaceLine.Checked then
        begin
          if S.Trim = '' then
            Continue;
        end;
        if chkTrimSpace.Checked then
          S := S.Trim;
        if chkAddQuote.Checked then
        begin
          case rgAddQuotes.ItemIndex of
            0: S := '''' + S + '''';
            1: S := '"' + S + '"';
          end;
        end;
        if chkAddCommaOnTail.Checked then
          S := S + ',';

        LResult.Add(S);
      end;
      FSrcData := LResult.Text;
    finally
      LResult.Free;
    end;
  finally
    LStrs.Free;
  end;
end;

end.
