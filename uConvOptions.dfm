object frmConvOptions: TfrmConvOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #23383#31526#20018#22788#29702
  ClientHeight = 249
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 394
    Height = 196
    Align = alClient
    Caption = #36873#39033
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 373
    ExplicitHeight = 161
    object chkRemoveSpaceLine: TCheckBox
      Left = 16
      Top = 24
      Width = 81
      Height = 17
      Caption = #31227#38500#31354#34892
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object rgAddQuotes: TRadioGroup
      Left = 16
      Top = 87
      Width = 342
      Height = 42
      Caption = #23383#31526#28155#21152#28155#21152#24341#21495#36873#39033
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        #21333#24341#21495
        #21452#24341#21495)
      TabOrder = 4
    end
    object chkTrimSpace: TCheckBox
      Left = 111
      Top = 24
      Width = 74
      Height = 17
      Caption = #21024#39318#23614#31354
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object chkAddCommaOnTail: TCheckBox
      Left = 208
      Top = 24
      Width = 97
      Height = 17
      Caption = #32467#23614#28155#21152#36887#21495
      TabOrder = 2
    end
    object chkAddQuote: TCheckBox
      Left = 16
      Top = 56
      Width = 129
      Height = 17
      Caption = #23383#31526#39318#23614#28155#21152#24341#21495
      TabOrder = 3
    end
  end
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 205
    Width = 394
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 181
    ExplicitTop = 216
    ExplicitWidth = 185
    object Button1: TButton
      Left = 152
      Top = 8
      Width = 75
      Height = 25
      Caption = #25191#34892
      ModalResult = 1
      TabOrder = 0
    end
  end
end
