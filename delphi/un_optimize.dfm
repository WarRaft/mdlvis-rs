object frm_optimize: Tfrm_optimize
  Left = 192
  Top = 114
  BorderStyle = bsDialog
  Caption = 'Оптимизатор'
  ClientHeight = 341
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 75
    Height = 16
    Caption = 'Действия:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 264
    Top = 8
    Width = 78
    Height = 16
    Caption = 'Описание:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object clb_actions: TCheckListBox
    Left = 8
    Top = 24
    Width = 249
    Height = 281
    ItemHeight = 13
    Items.Strings = (
      'Канонизация'
      'Удаление повторяющихся поверхностей'
      'Удаление свободных вершин'
      'Удаление несвязанных костей'
      'Удаление ничейных КК'
      'Линеаризация анимации'
      'Увеличение сжимаемости (только MDX)')
    TabOrder = 0
    OnClick = clb_actionsClick
  end
  object Button1: TButton
    Left = 104
    Top = 312
    Width = 97
    Height = 25
    Caption = 'Оптимизировать'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 320
    Top = 312
    Width = 97
    Height = 25
    Caption = 'Отмена'
    Default = True
    TabOrder = 2
    OnClick = Button2Click
  end
  object ed_action: TMemo
    Left = 264
    Top = 24
    Width = 265
    Height = 281
    ReadOnly = True
    TabOrder = 3
  end
end
