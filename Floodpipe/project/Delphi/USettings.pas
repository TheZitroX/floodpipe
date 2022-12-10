{
    file:       USettings.pas
    author:     John Lienau
    title:      Settings unit of project Floodpipe
    version:    v1.0
    date:       03.08.2022
    copyright:  Copyright (c) 2022

    brief:      This unit contains the settings form of the application
                and all the methods that are called by the form
}

unit USettings;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.NumberBox,
    Vcl.ExtCtrls;

type
    // Settings form class declaration with all the controls and methods that are called by the form elements
    TFSettings = class(TForm)
        nbColumns: TNumberBox;
        nbRows: TNumberBox;
        nbWallPercentage: TNumberBox;
        nbAnimationTime: TNumberBox;
        cbOverflow: TCheckBox;
        gridButtons: TGridPanel;
        btnOkay: TButton;
        btnCencel: TButton;
    gridSettings: TGridPanel;
    textColumn: TStaticText;
    textRow: TStaticText;
    textWallPercentage: TStaticText;
    textAnimationTime: TStaticText;
    private
        { Private declarations }
    public
        { Public declarations }
    end;

var FSettings: TFSettings; // Settings form variable declaration

implementation

    {$R *.dfm} // Form resource file

    // nothing to see here, move along
end.
