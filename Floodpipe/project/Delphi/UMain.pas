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
        procedure FormResize(Sender: TObject);

        public
            // panel
            panelGameArea:TPanel;
            panelRightSideArea:TPanel;
            panelRightSideInfo:TPanel;
            panelButtons:TPanel;
            panelGamefield:TPanel;
	end;

var
	FMain: TFMain;

implementation

{$R *.dfm}


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

    // create panel-layout
    // panel game area
    panelSetup(panelGameArea, FMain, 'panelGameArea');
    // panel gamefield
    panelSetup(panelGamefield, panelGameArea, 'panelGamefield');
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
        panelGamefield,
        panelRightSideArea,
        panelRightSideInfo,
        panelButtons
    );
end;

procedure TFMain.FormResize(Sender: TObject);
begin
    panelRedraw(
        FMain.ClientWidth,
        FMain.ClientHeight,
        panelGameArea,
        panelGamefield,
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
            var Resize: not used
}
procedure TFMain.FormCanResize(
    Sender: TObject;
    var newWidth, newHeight: Integer;
    var Resize: Boolean);
begin
    newHeight:=round(MAIN_FORM_ASPECT_RATIO * newWidth);
end;

end.