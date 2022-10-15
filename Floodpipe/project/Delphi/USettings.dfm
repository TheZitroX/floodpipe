object FSettings: TFSettings
  Left = 0
  Top = 0
  Caption = 'Settings'
  ClientHeight = 124
  ClientWidth = 120
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object nbColumns: TNumberBox
    Left = 8
    Top = 8
    Width = 25
    Height = 17
    MinValue = 2.000000000000000000
    MaxValue = 50.000000000000000000
    TabOrder = 0
    Value = 10.000000000000000000
    UseMouseWheel = True
  end
  object nbRows: TNumberBox
    Left = 8
    Top = 31
    Width = 25
    Height = 17
    MinValue = 2.000000000000000000
    MaxValue = 50.000000000000000000
    TabOrder = 1
    Value = 10.000000000000000000
    UseMouseWheel = True
  end
  object nbWallPercentage: TNumberBox
    Left = 8
    Top = 54
    Width = 25
    Height = 17
    MaxValue = 50.000000000000000000
    TabOrder = 2
    Value = 10.000000000000000000
    UseMouseWheel = True
  end
  object nbAnimationTime: TNumberBox
    Left = 8
    Top = 77
    Width = 49
    Height = 17
    MaxValue = 1000.000000000000000000
    TabOrder = 3
    Value = 10.000000000000000000
    UseMouseWheel = True
  end
  object cbOverflow: TCheckBox
    Left = 8
    Top = 100
    Width = 97
    Height = 17
    Caption = 'Overflow'
    TabOrder = 4
  end
end
