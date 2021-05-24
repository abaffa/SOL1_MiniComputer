object foptions: Tfoptions
  Left = 487
  Top = 418
  Width = 406
  Height = 394
  Caption = 'Options'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 398
    Height = 161
    Align = alClient
    Caption = 'BIOS / Text files'
    TabOrder = 0
    object CheckBox1: TCheckBox
      Left = 16
      Top = 24
      Width = 201
      Height = 17
      Caption = 'Show replace-prompt at Save'
      TabOrder = 0
    end
    object Button15: TButton
      Left = 15
      Top = 59
      Width = 98
      Height = 21
      Caption = 'Choose Font'
      TabOrder = 1
    end
    object Button1: TButton
      Left = 119
      Top = 59
      Width = 98
      Height = 21
      Caption = 'Background color'
      TabOrder = 2
    end
    object Button3: TButton
      Left = 223
      Top = 59
      Width = 98
      Height = 21
      Caption = 'Font color'
      TabOrder = 3
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 161
    Width = 398
    Height = 155
    Align = alBottom
    Caption = 'GroupBox2'
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 316
    Width = 398
    Height = 51
    Align = alBottom
    TabOrder = 2
    object Button2: TButton
      Left = 160
      Top = 12
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
      OnClick = Button2Click
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 632
    Top = 280
  end
  object ColorDialog1: TColorDialog
    Ctl3D = True
    Left = 152
    Top = 176
  end
end
