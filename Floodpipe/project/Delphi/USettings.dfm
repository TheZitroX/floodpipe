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
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object gridButtons: TGridPanel
    Left = 0
    Top = 190
    Width = 216
    Height = 41
    Align = alBottom
    ColumnCollection = <
      item
        Value = 33.333333333333340000
      end
      item
        Value = 33.333333333333330000
      end
      item
        Value = 33.333333333333330000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = btnOkay
        Row = 0
      end
      item
        Column = 2
        Control = btnCencel
        Row = 0
      end
      item
        Column = 0
        ColumnSpan = 2
        Row = 1
      end>
    RowCollection = <
      item
        Value = 100.000000000000000000
      end
      item
        SizeStyle = ssAuto
      end>
    ShowCaption = False
    TabOrder = 0
    object btnOkay: TButton
      Left = 1
      Top = 1
      Width = 71
      Height = 39
      Align = alClient
      Caption = 'Okay'
      ModalResult = 1
      TabOrder = 0
    end
    object btnCencel: TButton
      Left = 144
      Top = 1
      Width = 71
      Height = 39
      Align = alClient
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object gridSettings: TGridPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 210
    Height = 184
    Align = alClient
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
        ColumnSpan = 2
        Control = cbOverflow
        Row = 0
      end
      item
        Column = 1
        Control = nbColumns
        Row = 1
      end
      item
        Column = 1
        Control = nbAnimationTime
        Row = 4
      end
      item
        Column = 1
        Control = nbRows
        Row = 2
      end
      item
        Column = 1
        Control = nbWallPercentage
        Row = 3
      end
      item
        Column = 0
        Control = textColumn
        Row = 1
      end
      item
        Column = 0
        Control = textRow
        Row = 2
      end
      item
        Column = 0
        Control = textWallPercentage
        Row = 3
      end
      item
        Column = 0
        Control = textAnimationTime
        Row = 4
      end>
    RowCollection = <
      item
        Value = 20.000000000000000000
      end
      item
        Value = 20.000000000000000000
      end
      item
        Value = 20.000000000000000000
      end
      item
        Value = 20.000000000000000000
      end
      item
        Value = 20.000000000000000000
      end>
    ShowCaption = False
    TabOrder = 1
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 216
    ExplicitHeight = 190
    object cbOverflow: TCheckBox
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 202
      Height = 30
      Align = alClient
      Alignment = taLeftJustify
      Caption = 'Overflow'
      TabOrder = 0
      ExplicitWidth = 208
      ExplicitHeight = 32
    end
    object nbColumns: TNumberBox
      AlignWithMargins = True
      Left = 108
      Top = 40
      Width = 98
      Height = 31
      Align = alClient
      Alignment = taRightJustify
      MinValue = 2.000000000000000000
      MaxValue = 50.000000000000000000
      TabOrder = 1
      Value = 10.000000000000000000
      UseMouseWheel = True
      ExplicitTop = 39
      ExplicitWidth = 107
      ExplicitHeight = 21
    end
    object nbAnimationTime: TNumberBox
      AlignWithMargins = True
      Left = 108
      Top = 150
      Width = 98
      Height = 30
      Align = alClient
      Alignment = taRightJustify
      MaxValue = 1000.000000000000000000
      TabOrder = 2
      Value = 10.000000000000000000
      UseMouseWheel = True
      ExplicitTop = 151
      ExplicitWidth = 107
      ExplicitHeight = 21
    end
    object nbRows: TNumberBox
      AlignWithMargins = True
      Left = 108
      Top = 77
      Width = 98
      Height = 30
      Align = alClient
      Alignment = taRightJustify
      MinValue = 2.000000000000000000
      MaxValue = 50.000000000000000000
      TabOrder = 3
      Value = 10.000000000000000000
      UseMouseWheel = True
      ExplicitTop = 76
      ExplicitWidth = 107
      ExplicitHeight = 21
    end
    object nbWallPercentage: TNumberBox
      AlignWithMargins = True
      Left = 108
      Top = 113
      Width = 98
      Height = 31
      Align = alClient
      Alignment = taRightJustify
      MaxValue = 50.000000000000000000
      TabOrder = 4
      Value = 10.000000000000000000
      UseMouseWheel = True
      ExplicitTop = 114
      ExplicitWidth = 107
      ExplicitHeight = 21
    end
    object textColumn: TStaticText
      AlignWithMargins = True
      Left = 4
      Top = 40
      Width = 98
      Height = 31
      Align = alClient
      Caption = 'Columns'
      TabOrder = 5
      ExplicitTop = 42
      ExplicitWidth = 101
    end
    object textRow: TStaticText
      AlignWithMargins = True
      Left = 4
      Top = 77
      Width = 98
      Height = 30
      Align = alClient
      Caption = 'Rows'
      TabOrder = 6
      ExplicitTop = 79
      ExplicitWidth = 101
      ExplicitHeight = 32
    end
    object textWallPercentage: TStaticText
      AlignWithMargins = True
      Left = 4
      Top = 113
      Width = 98
      Height = 31
      Align = alClient
      Caption = 'Wall Percentage'
      TabOrder = 7
      ExplicitTop = 117
      ExplicitWidth = 101
    end
    object textAnimationTime: TStaticText
      AlignWithMargins = True
      Left = 4
      Top = 150
      Width = 98
      Height = 30
      Align = alClient
      Caption = 'Animation Time (ms)'
      TabOrder = 8
      ExplicitTop = 154
      ExplicitWidth = 101
      ExplicitHeight = 32
    end
  end
end
