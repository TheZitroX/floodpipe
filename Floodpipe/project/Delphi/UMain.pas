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
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,

    UProperties, UFunctions, UTypedefine, UCellFunctions, UFluid, UPositionFunctions;

type
    TFMain = class(TForm)
        procedure FormCanResize(Sender: TObject;
          var NewWidth, NewHeight: Integer; var Resize: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormResize(Sender: TObject);
        procedure updateLayout();
        procedure cellQueueHandler(Sender: TObject);
        procedure cellQueueHandlerFinalize();
        procedure onCellClick(Sender: TObject);
        procedure onNewButtonClick(Sender: TObject);
        procedure animationStart();
        procedure finalizeAnimation();

    public
        // panel
        panelGameArea: TPanel;
        panelRightSideArea: TPanel;
        panelRightSideInfo: TPanel;
        panelButtons: TPanel;
        panelGamefield: TPanel;

        // buttons
        newGameButton: TButton;
        loadGameButton: TButton;
        saveGameButton: TButton;
        exitGameButton: TButton;

        // ---gamefield---
        cellGrid: TGridPanel;
        // gamefield cells
        cellField: TCellField;
        cellRowLength: Integer;
        cellColumnLength: Integer;
    end;

var
    FMain: TFMain;
    cellAnimationTickRate: Integer;
    positionQueueList: TPositionList;
    timerCount: integer;
    fluidTimer: TTimer;
    isSimulating: boolean;

implementation

{$R *.dfm}

procedure TFMain.onNewButtonClick(Sender: TObject);
begin
    animationStart();
end;

procedure TFMain.onCellClick(Sender: TObject);
var
    position: TPosition;
begin
    if isSimulating then begin
    end else begin
        // position := getPositionFromName(TImage(Sender).name);
        // rotateCellClockwise(
        //     cellField[
        //         position.x,
        //         position.y
        //     ]
        // );
        if setWaterSource(
            cellField,
            positionQueueList,
            getPositionFromName(TImage(Sender).name)
        ) then;
    end;
end;

{
    Calles the panelRedraw procedure to update all positions and sizes
}
procedure TFMain.updateLayout();
begin
    // update positions
    panelRedraw(FMain.ClientWidth, FMain.ClientHeight, panelGameArea,
      panelGamefield, panelRightSideArea, panelRightSideInfo, panelButtons);
end;

procedure TFMain.cellQueueHandlerFinalize();
begin
    finalizeAnimation();
    // todo set leak positions on field
end;

{
    Works through the positionQueueList

    Global: positionQueueList die abzuarbeiten ist
}
procedure TFMain.cellQueueHandler(Sender: TObject);
begin
    // disable to get no overflow when waiting for fluidMove(...)
    (Sender as TTimer).Enabled := false;

    // stop animation when finished
    if isPositionListEmpty(positionQueueList) then begin
        cellQueueHandlerFinalize();
    end else begin
        fluidMove(cellField, positionQueueList);
        // continiue animation
        (Sender as TTimer).Enabled := true;
    end;
end;

{
    Setup before the FMain shows
    Panels, buttons and the game is setup here

    @param  Sender: not used
}
procedure TFMain.FormCreate(Sender: TObject);
begin
    // inizialize
    positionQueueList.firstNode := nil;
    
    // set default values
    cellRowLength := DEFAULT_CELL_ROW_COUNT;
    cellColumnLength := DEFAULT_CELL_COLUMN_COUNT;
    cellAnimationTickRate := DEFAULT_CELL_TICK_RATE;

    // for randomniss
    randomize;

    // FMain setup
    FMain.Constraints.MinWidth := MAIN_FORM_MIN_WIDTH;
    FMain.Constraints.MinHeight := MAIN_FORM_MIN_HEIGHT;
    // create panel-layout
    // panel game area
    panelSetup(panelGameArea, FMain, 'panelGameArea');
    // panel gamefield
    panelSetup(panelGamefield, panelGameArea, 'panelGamefield');
    // gridpanel cellGrid
    createCellGrid(cellGrid, panelGamefield, cellField, cellRowLength,
      cellColumnLength, onCellClick);
    // panel right side area
    panelSetup(panelRightSideArea, FMain, 'panelSetup');
    // panel Right side info
    panelSetup(panelRightSideInfo, panelRightSideArea, 'panelRightSideInfo');
    // panel Right side info
    panelSetup(panelButtons, panelRightSideArea, 'panelButtons');

    // buttons with panelButtons as parent
    createButtons(
        newGameButton, onNewButtonClick,
        loadGameButton,
        saveGameButton,
        exitGameButton,
        panelButtons
    );

    updateLayout();

    // todo aufruf bei animation
    // flow start
    // fix testwise
    // if setWaterSource(cellField, positionQueueList, getPosition(5, 5)) then;
    fluidTimer := TTimer.Create(FMain);
    with fluidTimer do begin
        Interval := cellAnimationTickRate;
        OnTimer := FMain.cellQueueHandler;
        Enabled := false;
    end;
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

procedure TFMain.animationStart();
    procedure deactivateUserInteraction();
    begin
        newGameButton.enabled := false;
        loadGameButton.enabled := false;
        saveGameButton.enabled := false;
    end;
begin
    isSimulating := true;
    deactivateUserInteraction();
    fluidTimer.Enabled := true;
end;

procedure TFMain.finalizeAnimation();
    procedure activateUserInteraction();
    begin
        newGameButton.enabled := true;
        loadGameButton.enabled := true;
        saveGameButton.enabled := true;
    end;
begin
    isSimulating := false;
    activateUserInteraction();
end;

end.