{
    file:       UMain.pas
    author:     John Lienau
    title:      Main unit of project Floodpipe
    version:    v1.0
    date:       29.07.2022
    copyright:  Copyright (c) 2022

    brief:      Main implementations of all units of the project Floodpipe
}

unit UMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,

	UProperties, UFunctions;

type
	TFMain = class(TForm)
        procedure FormCanResize(Sender: TObject; var NewWidth,
                NewHeight: Integer; var Resize: Boolean);
        procedure FormCreate(Sender: TObject);

        public
            // panel
            panelGameArea:TPanel;
            panelRightSideArea:TPanel;
            panelRightSideInfo:TPanel;
            panelButtons:TPanel;
	end;

var
	FMain: TFMain;
    fMainResizing:boolean;

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
    var panelGameArea:TPanel;
    var panelRightSideArea:TPanel;
    var panelRightSideInfo:TPanel;
    var panelButtons:TPanel);

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
    // panelGameArea
    setDimentions(
        panelGameArea,
        0, 0, // pos(0, 0)
        (mainWidth * 80) div 100, // 80% of the Width
        mainHeight
    );

    // panelRightSideArea
    setDimentions(
        panelRightSideArea,
        0, // top of FMain
        (mainWidth * 80) div 100, // 80% of the Width
        (mainWidth * 20) div 100, // 20% of the Width
        mainHeight
    );

    // panelRightSideInfo
    setDimentions(
        panelRightSideInfo,
        0, // top of FMain
        0, // 80% of the Width
        panelRightSideArea.Width,
        (panelRightSideArea.Height * 33) div 100 // 33% height of panelRightSideArea
    );

    // panelRightSideInfo
    setDimentions(
        panelButtons,
        (panelRightSideArea.Height * 33) div 100, // 33% height of panelRightSideArea
        0,
        panelRightSideArea.Width,
        (panelRightSideArea.Height * 67) div 100 // 67% height of panelRightSideArea
    );
end;

{
    Setup before the FMain shows
    Panels, buttons and the game is setup here

    @param  Sender: not used
}
procedure TFMain.FormCreate(Sender: TObject);
begin
    // FMain setup
    FMain.Constraints.MinWidth := MAIN_FORM_MIN_WIDTH;
    FMain.Constraints.MinHeight := MAIN_FORM_MIN_HEIGHT;

    // accessviolation if panels resizes when not existing
    // starting with false and after creation the 
    // FormCanResize triggers and sets itself to true
    fMainResizing := false;

    // create panel-layout
    // panel game area
    panelSetup(panelGameArea, FMain, 'panelGameArea');
    // panel right side area
    panelSetup(panelRightSideArea, FMain, 'panelSetup');
    // panel Right side info
    panelSetup(panelRightSideInfo, panelRightSideArea, 'panelRightSideInfo');
    // panel Right side info
    panelSetup(panelButtons, panelRightSideArea, 'panelButtons');

    // update positions
    panelRedraw(
        FMain.ClientWidth,
        FMain.ClientHeight,
        panelGameArea,
        panelRightSideArea,
        panelRightSideInfo,
        panelButtons
    );
end;

{
    On Resize the aspect ratio will be maintained
    // fixme Horizontal sizing is not possible

    @param  Sender: not used
            var NewWidth: used to get the Width
            var NewHeight: changed the height of the form
}
procedure TFMain.FormCanResize(
    Sender: TObject;
    var newWidth, newHeight: Integer;
    var Resize: Boolean);
begin
    newHeight:=round(MAIN_FORM_ASPECT_RATIO * newWidth);

    if fMainResizing then
        panelRedraw(
            FMain.ClientWidth,
            FMain.ClientHeight,
            panelGameArea,
            panelRightSideArea,
            panelRightSideInfo,
            panelButtons
        );

    // set true to be able so resize after Form is created
    fMainResizing := true;
end;

end.