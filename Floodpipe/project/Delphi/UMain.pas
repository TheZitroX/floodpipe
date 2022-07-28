{
    file:       UMain.pas
    author:     John Lienau
    title:      Main unit of project Floodpipe
    version:    v1.0
    date:       28.07.2022
    copyright:  Copyright (c) 2022

    brief:      Main implementations of all units of the project Floodpipe
}

unit UMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,

	UProperties;

type
	TFMain = class(TForm)
        //panel
        panelGameArea:TPanel;

        procedure FormCanResize(Sender: TObject; var NewWidth,
                NewHeight: Integer; var Resize: Boolean);
        procedure FormCreate(Sender: TObject);
	end;

var
	FMain: TFMain;

implementation

{$R *.dfm}

{
    Gives each panel its position and size,
    relativ to the width and height of the FMain size

    @param  mainWidth: width of FMain
            mainHeight: newHeight of FMain
            var panelGameArea: the Gamearea panel
}
procedure panelRedraw(
    mainWidth, mainHeight:integer;
    panelGameArea:TPanel);

    procedure setDimentions(
        var panel:TPanel;
        newTop, newLeft, newWidth, newHeight:integer);
    begin
        with panel do
        begin
            Top := newTop;
            Left := newLeft;
            Width := newWidth;
            Height := newHeight;
        end;
    end;

begin
    setDimentions(
        panelGameArea,
        0, 0,
        (mainWidth * 80) div 100, // 80% of the Width
        mainHeight);
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
    // create panel-layout
    panelGameArea := TPanel.Create(FMain);
    panelGameArea.Parent := FMain;
    panelRedraw(
        FMain.Width,
        FMain.Height,
        panelGameArea
    );
end;

{
    On Resize the aspect ratio will be maintained

    @param  Sender: not used
            var NewWidth: used to get the Width
            var NewHeight: changed the height of the form
}
procedure TFMain.FormCanResize(
    Sender: TObject;
    var NewWidth, NewHeight: Integer;
    var Resize: Boolean);
begin
    NewHeight:=round(MAIN_FORM_ASPECT_RATIO * NewWidth);

    panelRedraw(
        FMain.width,
        FMain.height,
        panelGameArea
    );
end;

end.