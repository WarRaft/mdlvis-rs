object frm_warn: Tfrm_warn
  Left = 173
  Top = 21
  BorderStyle = bsDialog
  Caption = 'Внимание!'
  ClientHeight = 483
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object mm: TMemo
    Left = 0
    Top = 0
    Width = 536
    Height = 449
    Align = alTop
    Color = clSilver
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Button1: TButton
    Left = 224
    Top = 456
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
end
