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

    USettings,

    UProperties, UFunctions, UTypedefine, UCellFunctions, UFluid,
    UPositionFunctions, UGameGeneration;

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
        procedure onCellMouseDown(
            Sender: TObject;
            Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer
        );
        procedure animationStart();
        procedure finalizeAnimation();
        procedure enableSimulationMode(b: Boolean);
        procedure formSetup();
        procedure setFSettingsFromSettings();
        function getSettingsFromFSettings(): Boolean;

        // buttonMethods
        procedure onGamemodeButtonClick(Sender: TObject);
        procedure onNewButtonClick(Sender: TObject);
        procedure onSettingsButtonClick(Sender: TObject);
        procedure onItemChooseClick(Sender: TObject);

    public
        // panel
        panelGameArea: TPanel;
        panelRightSideArea: TPanel;
        panelRightSideInfo: TPanel;
        panelButtons: TPanel;
        panelGamefield: TPanel;

        // buttons
        pipeLidButton: TButton;
        pipeButton: TButton;
        pipeTSplitButton: TButton;
        pipeCurveButton: TButton;
        gamemodeButton: TButton;

        newGameButton: TButton;
        settingsButton: TButton;
        loadGameButton: TButton;
        saveGameButton: TButton;
        exitGameButton: TButton;

        // ---gamefield---
        cellGrid: TGridPanel;
        // gamefield cells
        cellField: TCellField;
        cellRowLength: Integer;
        cellColumnLength: Integer;
        wallPercentage: Integer;

    private
        procedure setItemButtonVisibility(b:boolean);
    end;

var
    FMain: TFMain;
    cellAnimationTickRate: Integer;
    waterSourcePositionQueueList: TPositionList;
    timerCount: Integer;
    fluidTimer: TTimer;
    isSimulating: Boolean;
    isEditorMode: boolean;
    checkedItem: TItemButton;
    oldButton: TButton;

implementation

{$R *.dfm}

procedure TFMain.onItemChooseClick(Sender: TObject);
begin
    if (oldButton <> nil) then
    begin
        // remove font style of old button
        oldButton.font.style := [];
    end;

    if (checkedItem = TItemButton((Sender as TButton).tag)) then
        checkedItem := NONE_BUTTON
    else checkedItem := TItemButton((Sender as TButton).tag);

    case checkedItem of
        PIPE_LID_BUTTON:
        begin
            (Sender as TButton).font.style := [fsBold];
        end;
        PIPE_BUTTON:
        begin
            (Sender as TButton).font.style := [fsBold];
        end;
        PIPE_TSPLIT_BUTTON:
        begin
            (Sender as TButton).font.style := [fsBold];
        end;
        PIPE_CURVE_BUTTON:
        begin
            (Sender as TButton).font.style := [fsBold];
        end;
        WALL_BUTTON:
        begin
            (Sender as TButton).font.style := [fsBold];
        end;
        else; // maybe assertions
    end;

    oldButton := (Sender as TButton);
end;

procedure TFMain.setItemButtonVisibility(b:boolean);
begin
    pipeLidButton.visible := b;
    pipeButton.visible := b;
    pipeTSplitButton.visible := b;
    pipeCurveButton.visible := b;
end;

procedure TFMain.onGamemodeButtonClick(Sender: TObject);
begin
    isEditorMode := not isEditorMode;

    // changing to editormode
    if (isEditorMode) then
    begin
        gamemodeButton.caption := 'Editor';
        setItemButtonVisibility(true);
    end
    else // isEditorMode == false
    begin
        gamemodeButton.caption := 'Playing';
        checkedItem := NONE_BUTTON;
        // remove font style of old button
        if (oldButton <> nil) then
            oldButton.font.style := [];
        setItemButtonVisibility(false);
    end;
end;

procedure TFMain.onNewButtonClick(Sender: TObject);
begin
    animationStart();
end;

procedure TFMain.onSettingsButtonClick(Sender: TObject);
begin
    case FSettings.ShowModal of
        mrOk:
        begin
            // settings übernehmen welche die simulation beeinflussen würde
            if (not isSimulating) then
            begin
                if getSettingsFromFSettings() then
                begin
                    // todo ask for window reload
                    removeCellGrid(cellGrid, cellField);
                    createCellGrid(cellGrid, panelGamefield, cellField, cellRowLength,
                        cellColumnLength, onCellMouseDown);
                    generateGame(cellField, cellRowLength, cellColumnLength,
                        wallPercentage, waterSourcePositionQueueList);
                end;
            end;
        end;
        mrCancel:
            setFSettingsFromSettings();
    end;
end;

procedure TFMain.onCellMouseDown(
    Sender: TObject;
    Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer
);
var position:TPosition;
begin
    if not isSimulating then
    begin
        if isEditorMode then
        begin
            position := getPositionFromName(TImage(Sender).name);
            case Button of
                mbLeft: onCellClick(Sender);
                mbRight: rotateCellClockwise(
                    cellField[position.x, position.y]
                );
                mbMiddle: setCellFieldToItem(
                    cellField,
                    TYPE_WALL,
                    PIPE,
                    CONTENT_EMPTY,
                    NONE
                );
            end; 
        end
        else // not editor mode
            onCellClick(Sender);
    end;
end;

procedure TFMain.onCellClick(Sender: TObject);
var position: TPosition;
begin
    if not isSimulating then
    begin
        position := getPositionFromName(TImage(Sender).name);

        case checkedItem of
        NONE_BUTTON:
        begin
            rotateCellClockwise(
                cellField[
                    position.x,
                    position.y
                ]
            );
            // fixme change back to rotation when finished debuggin
            // if setWaterSource(cellField, waterSourcePositionQueueList,
            //   getPositionFromName(TImage(Sender).name)) then;
        end;
        PIPE_LID_BUTTON:
        begin
            setCellToItem(
                cellField[position.x, position.y],
                TYPE_PIPE,
                PIPE_LID,
                CONTENT_EMPTY,
                NONE
            );
        end;
        PIPE_BUTTON:
        begin
            setCellToItem(
                cellField[position.x, position.y],
                TYPE_PIPE,
                PIPE,
                CONTENT_EMPTY,
                NONE
            );
        end;
        PIPE_TSPLIT_BUTTON:
        begin
            setCellToItem(
                cellField[position.x, position.y],
                TYPE_PIPE,
                PIPE_TSPLIT,
                CONTENT_EMPTY,
                NONE
            );
        end;
        PIPE_CURVE_BUTTON:
        begin
            setCellToItem(
                cellField[position.x, position.y],
                TYPE_PIPE,
                PIPE_CURVES,
                CONTENT_EMPTY,
                NONE
            );
        end;
        WALL_BUTTON:
        begin
            setCellToItem(
                cellField[position.x, position.y],
                TYPE_WALL,
                PIPE_LID,
                CONTENT_EMPTY,
                NONE
            );
        end;

        else showmessage('no such item');
        end;
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
  sets values from membervariables to FSettings
}
procedure TFMain.setFSettingsFromSettings();
begin
    FSettings.nbRows.Value := cellRowLength;
    FSettings.nbColumns.Value := cellColumnLength;
    FSettings.nbAnimationTime.Value := cellAnimationTickRate;
end;

{
  gets values from FSettings and puts them in membervariables

  @return     true when a new-build needs to be made
}
function TFMain.getSettingsFromFSettings(): Boolean;
begin
    getSettingsFromFSettings := 
        (cellRowLength <> round(FSettings.nbRows.Value)) or
        (cellColumnLength <> round(FSettings.nbColumns.Value)) or
        (wallPercentage <> round(FSettings.nbWallPercentage.Value));

    cellRowLength := round(FSettings.nbRows.Value);
    cellColumnLength := round(FSettings.nbColumns.Value);
    wallPercentage := round(FSettings.nbWallPercentage.Value);

    // no new-build needed when those settings change
    cellAnimationTickRate := round(FSettings.nbAnimationTime.Value);
    fluidtimer.interval := cellAnimationTickRate;
end;

{
  Works through the waterSourcePositionQueueList

  Global: waterSourcePositionQueueList die abzuarbeiten ist
}
procedure TFMain.cellQueueHandler(Sender: TObject);
begin
    // disable to get no overflow when waiting for fluidMove(...)
    (Sender as TTimer).Enabled := false;

    // stop animation when finished
    if isPositionListEmpty(waterSourcePositionQueueList) then
    begin
        cellQueueHandlerFinalize();
    end
    else
    begin
        fluidMove(cellField, waterSourcePositionQueueList);
        // continiue animation
        (Sender as TTimer).Enabled := true;
    end;
end;

procedure TFMain.formSetup();
begin
    // inizialize
    waterSourcePositionQueueList.firstNode := nil;
    checkedItem := NONE_BUTTON;
    oldButton := nil;

    // set default values
    cellRowLength := DEFAULT_CELL_ROW_COUNT;
    cellColumnLength := DEFAULT_CELL_COLUMN_COUNT;
    wallPercentage := DEFAULT_WALL_PERCENTAGE;
    cellAnimationTickRate := DEFAULT_CELL_TICK_RATE;

    // for randomniss
    randomize;

    // ===CREATE PANEL-LAYOUT===
    // panel game area
    panelSetup(panelGameArea, FMain, 'panelGameArea');
    // panel gamefield
    panelSetup(panelGamefield, panelGameArea, 'panelGamefield');
    // gridpanel cellGrid
    createCellGrid(cellGrid, panelGamefield, cellField, cellRowLength,
      cellColumnLength, onCellMouseDown);
    // panel right side area
    panelSetup(panelRightSideArea, FMain, 'panelSetup');
    // panel Right side info
    panelSetup(panelRightSideInfo, panelRightSideArea, 'panelRightSideInfo');
    createInfoButtons(panelrightSideInfo,
        pipeLidButton, pipeButton, pipeTSplitButton, pipeCurveButton, onItemChooseClick,
        gamemodeButton, onGamemodeButtonClick
    );
    // panel Right side info
    panelSetup(panelButtons, panelRightSideArea, 'panelButtons');
    // buttons with panelButtons as parent
    createButtons(newGameButton, onNewButtonClick, settingsButton,
      onSettingsButtonClick, loadGameButton, saveGameButton, exitGameButton,
      panelButtons);

    updateLayout();

    // todo aufruf bei animation
    // flow start
    // fix testwise
    // if setWaterSource(cellField, waterSourcePositionQueueList, getPosition(5, 5)) then;
    fluidTimer := TTimer.Create(FMain);
    with fluidTimer do
    begin
        Interval := cellAnimationTickRate;
        OnTimer := FMain.cellQueueHandler;
        Enabled := false;
    end;
end;

{
  Setup before the FMain shows
  Panels, buttons and the game is setup here

  @param  Sender: not used
}
procedure TFMain.FormCreate(Sender: TObject);
begin
    formSetup();

    generateGame(cellField, cellRowLength, cellColumnLength,
        wallPercentage, waterSourcePositionQueueList);
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
procedure TFMain.FormCanResize(Sender: TObject;
  var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
    NewHeight := round(MAIN_FORM_ASPECT_RATIO * NewWidth);
end;

{
  sets all buttons and inputfields enabled to b

  @param  IN:     b: true for enabled false for the oposite :)
}
procedure TFMain.enableSimulationMode(b: Boolean);
begin
    FSettings.nbColumns.Enabled := b;
    FSettings.nbRows.Enabled := b;
    FSettings.nbWallPercentage.Enabled := b;

    newGameButton.Enabled := b;
    loadGameButton.Enabled := b;
    saveGameButton.Enabled := b;
end;

{
  stating an animation and disable buttons
}
procedure TFMain.animationStart();
begin
    isSimulating := true;
    enableSimulationMode(false);
    fluidTimer.Enabled := true;
end;

{
  finishing an animation and enable buttons
}
procedure TFMain.finalizeAnimation();
begin
    isSimulating := false;
    enableSimulationMode(true);
end;

end.
