object frmAdd: TfrmAdd
  Left = 284
  Top = 235
  Width = 260
  Height = 165
  Caption = 'Вставка пустых кадров'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 89
    Height = 13
    Caption = 'Вставить кадров:'
  end
  object ed_count: TEdit
    Left = 112
    Top = 13
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '1000'
    OnKeyPress = ed_countKeyPress
  end
  object Button1: TButton
    Left = 40
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Вставить'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 144
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Отмена'
    TabOrder = 2
    OnClick = Button2Click
  end
end
