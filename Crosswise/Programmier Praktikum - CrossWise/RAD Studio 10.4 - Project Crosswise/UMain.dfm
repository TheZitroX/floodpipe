object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Crosswise'
  ClientHeight = 761
  ClientWidth = 984
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  Constraints.MaxHeight = 800
  Constraints.MaxWidth = 1000
  Constraints.MinHeight = 800
  Constraints.MinWidth = 1000
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  StyleElements = [seFont, seClient]
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object mainGamePanel: TPanel
    Left = 0
    Top = 0
    Width = 984
    Height = 761
    Align = alClient
    TabOrder = 0
    object infoPanel: TPanel
      Left = 798
      Top = 1
      Width = 185
      Height = 759
      Align = alRight
      BevelOuter = bvLowered
      TabOrder = 0
      object copyrightLabel: TLabel
        Left = 1
        Top = 748
        Width = 183
        Height = 10
        Align = alBottom
        Alignment = taCenter
        Caption = 'Demo v1.0 - 2022 John Lienau'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = cl3DDkShadow
        Font.Height = -8
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ExplicitWidth = 105
      end
      object aktionenPanel: TPanel
        Left = 1
        Top = 1
        Width = 183
        Height = 128
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 0
      end
      object optionButtonsPanel: TPanel
        Left = 1
        Top = 129
        Width = 183
        Height = 619
        Align = alClient
        TabOrder = 1
      end
    end
    object gamefieldPanel: TPanel
      Left = 1
      Top = 1
      Width = 797
      Height = 759
      Align = alClient
      TabOrder = 1
      OnClick = gamefieldPanelClick
      object playAreaPanel: TPanel
        Left = 225
        Top = 144
        Width = 400
        Height = 400
        Caption = 'playAreaPanel'
        TabOrder = 0
      end
    end
  end
end
