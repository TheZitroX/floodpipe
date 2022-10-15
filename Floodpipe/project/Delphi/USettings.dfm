object FSettings: TFSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 231
  ClientWidth = 216
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
    Left = 0
    Top = 0
    Width = 216
    Height = 17
    Align = alTop
    MinValue = 2.000000000000000000
    MaxValue = 50.000000000000000000
    TabOrder = 0
    Value = 10.000000000000000000
    UseMouseWheel = True
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 25
  end
  object nbRows: TNumberBox
    Left = 0
    Top = 17
    Width = 216
    Height = 17
    Align = alTop
    MinValue = 2.000000000000000000
    MaxValue = 50.000000000000000000
    TabOrder = 1
    Value = 10.000000000000000000
    UseMouseWheel = True
    ExplicitLeft = 8
    ExplicitTop = 31
    ExplicitWidth = 25
  end
  object nbWallPercentage: TNumberBox
    Left = 0
    Top = 34
    Width = 216
    Height = 17
    Align = alTop
    MaxValue = 50.000000000000000000
    TabOrder = 2
    Value = 10.000000000000000000
    UseMouseWheel = True
    ExplicitLeft = 8
    ExplicitTop = 54
    ExplicitWidth = 25
  end
  object nbAnimationTime: TNumberBox
    Left = 0
    Top = 51
    Width = 216
    Height = 17
    Align = alTop
    MaxValue = 1000.000000000000000000
    TabOrder = 3
    Value = 10.000000000000000000
    UseMouseWheel = True
    ExplicitLeft = 8
    ExplicitTop = 77
    ExplicitWidth = 49
  end
  object cbOverflow: TCheckBox
    Left = 0
    Top = 68
    Width = 216
    Height = 17
    Align = alTop
    Caption = 'Overflow'
    TabOrder = 4
    ExplicitLeft = 8
    ExplicitTop = 100
    ExplicitWidth = 97
  end
  object gridButtons: TGridPanel
    Left = 0
    Top = 190
    Width = 216
    Height = 41
    Align = alBottom
    ColumnCollection = <
      item
        Value = 50.000000000000000000
      end
      item
        Value = 50.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = btnOkay
        Row = 0
      end
      item
        Column = 1
        Control = btnCencel
        Row = 0
      end>
    RowCollection = <
      item
        Value = 100.000000000000000000
      end>
    ShowCaption = False
    TabOrder = 5
    ExplicitLeft = 23
    ExplicitTop = 120
    ExplicitWidth = 185
    object btnOkay: TButton
      Left = 1
      Top = 1
      Width = 107
      Height = 39
      Align = alClient
      Caption = 'Okay'
      ModalResult = 1
      Style = bsCommandLink
      TabOrder = 0
    end
    object btnCencel: TButton
      Left = 108
      Top = 1
      Width = 107
      Height = 39
      Align = alClient
      Caption = 'Cancel'
      ModalResult = 1
      TabOrder = 1
    end
  end
end
