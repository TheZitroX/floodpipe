{
    file:       UMain.pas
    author:     John Lienau
    title:      Main unit of project Floodpipe
    version:    v1.0
    date:       03.08.2022
    copyright:  Copyright (c) 2022

    brief:      Main implementations of all units of the project Floodpipe
}

unit UMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,

	UProperties, UFunctions, UTypedefine, UCellFunctions;

type
	TFMain = class(TForm)
        procedure FormCanResize(Sender: TObject; var NewWidth,
                NewHeight: Integer; var Resize: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormResize(Sender: TObject);
        procedure updateLayout();
        procedure cellQueueHandler(Sender: TObject);
        procedure cellQueueHandlerFinalize();
        procedure onCellClick(Sender: TObject);

        public
            // panel
            panelGameArea:TPanel;
            panelRightSideArea:TPanel;
            panelRightSideInfo:TPanel;
            panelButtons:TPanel;
            panelGamefield:TPanel;

            // buttons
            newGameButton:TButton;
            loadGameButton:TButton;
            saveGameButton:TButton;
            exitGameButton:TButton;

            // ---gamefield---
            cellGrid:TGridPanel;
            // gamefield cells
            cellField:TCellField;
            cellRowLength:integer;
            cellColumnLength:integer;
	end;

var
	FMain: TFMain;
    cellAnimationTickRate:integer;
    positionQueueList:TPositionList;

implementation

{$R *.dfm}

procedure TFMain.onCellClick(Sender: TObject);
var
    position:TPosition;
    cell:TCell;
begin
    cell.image := TImage(Sender);
    position := getPositionFromName(TImage(Sender).name);
    // showmessage('Hello from: ' + inttostr(position.x) + '|' + inttostr(position.y));
    rotateCellClockwise(cellField[position.x, position.y]);
end;

{
    Calles the panelRedraw procedure to update all positions and sizes
}
procedure TFMain.updateLayout();
begin
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

procedure TFMain.cellQueueHandlerFinalize();
begin
    // todo enable all buttons for user
end;

{
    Works through the positionQueueList

    Global: positionQueueList die abzuarbeiten ist
}
procedure TFMain.cellQueueHandler(Sender: TObject);
var
    outputString:TStringBuilder;
begin
    // if animationFinished() then
    // begin
        // timer stoppen
        (Sender as TTimer).Enabled := false;
        cellQueueHandlerFinalize();
    // end;

    outputString := TStringBuilder.Create;
    try
        outputString := outputString.Append('Hello World!');
        outputString := outputString.Append(sLineBreak);
        outputString := outputString.Append('positionQueueList:');
        outputString := outputString.Append(sLineBreak);

        showmessage(outputString.toString());
    finally
        outputString.Free;
    end;

end;

{
    Setup before the FMain shows
    Panels, buttons and the game is setup here

    @param  Sender: not used
}
procedure TFMain.FormCreate(Sender: TObject);
var
    t:TTimer;
begin
    cellRowLength := DEFAULT_CELL_ROW_COUNT;
    cellColumnLength := DEFAULT_CELL_COLUMN_COUNT;
    cellAnimationTickRate := DEFAULT_CELL_TICK_RATE;

    // for randomniss
    randomize;

    // todo aufruf bei animation
    // t := TTimer.Create(FMain);
    // t.Interval := cellAnimationTickRate;
    // t.OnTimer := FMain.cellQueueHandler;
    // t.Enabled := True;

    // FMain setup
    FMain.Constraints.MinWidth := MAIN_FORM_MIN_WIDTH;
    FMain.Constraints.MinHeight := MAIN_FORM_MIN_HEIGHT;
    // create panel-layout
    // panel game area
    panelSetup(panelGameArea, FMain, 'panelGameArea');
    // panel gamefield
    panelSetup(panelGamefield, panelGameArea, 'panelGamefield');
    // gridpanel cellGrid
    createCellGrid(
        cellGrid, panelGamefield, cellField,
        cellRowLength, cellColumnLength,
        onCellClick
    );
    // panel right side area
    panelSetup(panelRightSideArea, FMain, 'panelSetup');
    // panel Right side info
    panelSetup(panelRightSideInfo, panelRightSideArea, 'panelRightSideInfo');
    // panel Right side info
    panelSetup(panelButtons,panelRightSideArea, 'panelButtons');
    // buttons with panelButtons as parent
    createButtons(
        newGameButton,
        loadGameButton,
        saveGameButton,
        exitGameButton,
        panelButtons
    );

    updateLayout();
end;

procedure TFMain.FormResize(Sender: TObject);
begin
    updateLayout();
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