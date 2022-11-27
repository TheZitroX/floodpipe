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
    UPositionFunctions, UGameGeneration, UFileHandler;

type
    TFMain = class(TForm)

        {
            On Resize the aspect ratio will be maintained
            // fixme Horizontal sizing is not possible

            @param  IN      Sender: not used

                    IN/OUT  NewWidth: used to get the Width
                            NewHeight: changed the height of the form
                            Resize: not used
        }
        procedure FormCanResize(
            Sender: TObject;
            var NewWidth, NewHeight: Integer;
            var Resize: Boolean
        );

        {
            Setup before the FMain shows
            Panels, buttons and the game is setup here

            @param  IN      Sender: not used
        }
        procedure FormCreate(Sender: TObject);

        procedure formSetup();

        procedure FormResize(Sender: TObject);

        {
            Calles the panelRedraw procedure to update all positions and sizes
        }
        procedure updateLayout();

        {
            Timer works through the m_recGameStruct.waterSourcePositionQueueList

            @param  IN      Sender: the TTimer

                    Global  m_recGameStruct.waterSourcePositionQueueList die abzuarbeiten ist
        }
        procedure cellQueueHandler(Sender: TObject);

        procedure cellQueueHandlerFinalize();

        {
            stating an animation and disable buttons
        }
        procedure animationStart();

        {
            finishing an animation and enable buttons
        }
        procedure finalizeAnimation();

        {
            sets all buttons and inputfields enabled to b

            @param  IN      b: true for enabled false for the oposite :)
        }
        procedure enableSimulationMode(b: Boolean);

        {
            sets values from membervariables to FSettings
        }
        procedure setFSettingsFromSettings();

        {
            gets values from FSettings and puts them in membervariables

            @return true when a new-build needs to be made
        }
        function getSettingsFromFSettings(): Boolean;

        // ======buttonMethods======
        procedure onCellClick(Sender: TObject);
        procedure onCellMouseDown(
            Sender: TObject;
            Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer
        );
        procedure onGamemodeButtonClick(Sender: TObject);
        procedure onNewButtonClick(Sender: TObject);

        {
            opens a settings menu
            when specific changes has been made a game restart will be made

            @param  IN      Sender: the button 
        }
        procedure onSettingsButtonClick(Sender: TObject);
        
        {
            handles all side button onclick events

            @param  IN      Sender: the button
        }
        procedure onSideButtonClick(Sender: TObject);
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
        m_recGameStruct: TGameStruct;

    private
        procedure setItemButtonVisibility(b:boolean);
    end;

var
    FMain: TFMain;
    cellAnimationTickRate: Integer;
    timerCount: Integer;
    fluidTimer: TTimer;
    isSimulating: Boolean;
    isEditorMode: boolean;
    checkedItem: TItemButton;
    oldButton: TButton;

implementation

    {$R *.dfm}

    procedure TFMain.onSideButtonClick(Sender: TObject);
    var fileError:TFileError;
        oldCellField:TCellField;
    begin
        case TSideButton((Sender as TButton).tag) of
            GAMEMODE_BUTTON:
                onGamemodeButtonClick(Sender);

            NEW_BUTTON:
               onNewButtonClick(Sender);

            SETTINGS_BUTTON: 
                onSettingsButtonClick(Sender);

            LOAD_BUTTON:
            begin
                // todo abfrage ob geladen werden soll

                // save for deleting later when newCellField is generated
                oldCellField := m_recGameStruct.cellField;

                fileError := loadGameFromFile(
                    'Test',
                    m_recGameStruct,
                    panelGamefield,
                    onCellMouseDown,
                    cellGrid
                );
                case fileError of
                    FILE_ERROR_COUNT_NOT_READ_FROM_FILE: ShowMessage('coulnd read from file');

                    else;
                end;
                // load variables when no error accoured
                if (fileError = FILE_ERROR_NONE) then
                begin
                    removeCellGrid(cellGrid, oldCellField);
                    generateGameFromGameStruct(m_recGameStruct);
                end
                else
                begin
                    // fixme restore old gamefield when file is currupted
                end;
            end;

            SAVE_BUTTON:
                case saveGameToFile('Test', m_recGameStruct) of
                    FILE_ERROR_FILE_DOESNT_EXIST: showmessage('file doesnt exist');
                    FILE_ERROR_COULD_NOT_WRITE_TO_FILE: showmessage('could not write to file');

                    else;
                end;

            EXIT_BUTTON:
                // todo abfrage nach speichern oder ob geschlossen werden soll
                Application.Terminate;

            else; // nothing
        end;
    end;

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
            PIPE_LID_BUTTON,
            PIPE_BUTTON,
            PIPE_TSPLIT_BUTTON,
            PIPE_CURVE_BUTTON,
            WALL_BUTTON:
                (Sender as TButton).font.style := [fsBold];

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
                        removeCellGrid(cellGrid, m_recGameStruct.cellField);
                        createCellGrid(
                            cellGrid,
                            m_recGameStruct.waterSourcePositionQueueList,
                            panelGamefield,
                            m_recGameStruct.cellField, m_recGameStruct.cellRowLength,
                            m_recGameStruct.cellColumnLength,
                            onCellMouseDown,
                            true
                        );
                        generateGame(
                            m_recGameStruct.cellField,
                            m_recGameStruct.cellRowLength, m_recGameStruct.cellColumnLength,
                            m_recGameStruct.wallPercentage,
                            m_recGameStruct.waterSourcePositionQueueList
                        );
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
        i:integer;
    begin
        if not isSimulating then
        begin
            position := getPositionFromName(TImage(Sender).name);

            if isEditorMode then
            begin
                case Button of
                    mbLeft: onCellClick(Sender);
                    mbRight: rotateCellClockwise(
                        m_recGameStruct.cellField[position.x, position.y]
                    );
                    mbMiddle: setcellFieldToItem(
                        m_recGameStruct.cellField,
                        m_recGameStruct.waterSourcePositionQueueList,
                        TYPE_WALL,
                        PIPE,
                        CONTENT_EMPTY,
                        NONE
                    );
                end; 
            end
            else // not editor mode
            begin
                // onCellClick(Sender);
                case Button of
                    mbLeft: // rotate -90°
                        for i := 0 to 2 do
                            rotateCellClockwise(
                                m_recGameStruct.cellField[position.x, position.y]
                            );
                            
                    mbRight: // rotate 90°
                        rotateCellClockwise(
                            m_recGameStruct.cellField[position.x, position.y]
                        );

                    mbMiddle:; // nothing
                end; 
            end;
        end
        else // when simulating
            showmessage('No interaction durring simulation!');
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
                    m_recGameStruct.cellField[
                        position.x,
                        position.y
                    ]
                );
            end;
            PIPE_LID_BUTTON:
            begin
                setCellToItem(
                    m_recGameStruct.cellField[position.x, position.y],
                    m_recGameStruct.waterSourcePositionQueueList,
                    TYPE_PIPE,
                    PIPE_LID,
                    CONTENT_EMPTY,
                    NONE,
                    true
                );
            end;
            PIPE_BUTTON:
            begin
                setCellToItem(
                    m_recGameStruct.cellField[position.x, position.y],
                    m_recGameStruct.waterSourcePositionQueueList,
                    TYPE_PIPE,
                    PIPE,
                    CONTENT_EMPTY,
                    NONE,
                    true
                );
            end;
            PIPE_TSPLIT_BUTTON:
            begin
                setCellToItem(
                    m_recGameStruct.cellField[position.x, position.y],
                    m_recGameStruct.waterSourcePositionQueueList,
                    TYPE_PIPE,
                    PIPE_TSPLIT,
                    CONTENT_EMPTY,
                    NONE,
                    true
                );
            end;
            PIPE_CURVE_BUTTON:
            begin
                setCellToItem(
                    m_recGameStruct.cellField[position.x, position.y],
                    m_recGameStruct.waterSourcePositionQueueList,
                    TYPE_PIPE,
                    PIPE_CURVES,
                    CONTENT_EMPTY,
                    NONE,
                    true
                );
            end;
            WALL_BUTTON:
            begin
                setCellToItem(
                    m_recGameStruct.cellField[position.x, position.y],
                    m_recGameStruct.waterSourcePositionQueueList,
                    TYPE_WALL,
                    PIPE_LID,
                    CONTENT_EMPTY,
                    NONE,
                    true
                );
            end;

            else showmessage('no such item');
            end;
        end;
    end;

    procedure TFMain.updateLayout();
    begin
        // update positions
        panelRedraw(
            FMain.ClientWidth, FMain.ClientHeight,
            panelGameArea,
            panelGamefield,
            panelRightSideArea,
            panelRightSideInfo,
            panelButtons
        );
    end;

    procedure TFMain.cellQueueHandlerFinalize();
    begin
        finalizeAnimation();
        // todo set leak positions on field
    end;

    procedure TFMain.setFSettingsFromSettings();
    begin
        FSettings.nbRows.Value := m_recGameStruct.cellRowLength;
        FSettings.nbColumns.Value := m_recGameStruct.cellColumnLength;
        FSettings.nbAnimationTime.Value := cellAnimationTickRate;
    end;

    function TFMain.getSettingsFromFSettings(): Boolean;
    begin
        getSettingsFromFSettings := 
            (m_recGameStruct.cellRowLength <> round(FSettings.nbRows.Value)) or
            (m_recGameStruct.cellColumnLength <> round(FSettings.nbColumns.Value)) or
            (m_recGameStruct.wallPercentage <> round(FSettings.nbwallPercentage.Value));

        m_recGameStruct.cellRowLength := round(FSettings.nbRows.Value);
        m_recGameStruct.cellColumnLength := round(FSettings.nbColumns.Value);
        m_recGameStruct.wallPercentage := round(FSettings.nbwallPercentage.Value);

        // no new-build needed when those settings change
        cellAnimationTickRate := round(FSettings.nbAnimationTime.Value);
        fluidtimer.interval := cellAnimationTickRate;
    end;

    procedure TFMain.cellQueueHandler(Sender: TObject);
    begin
        // disable to get no overflow when waiting for fluidMove(...)
        (Sender as TTimer).Enabled := false;

        // stop animation when finished
        if isPositionListEmpty(m_recGameStruct.waterSourcePositionQueueList) then
        begin
            cellQueueHandlerFinalize();
        end
        else
        begin
            fluidMove(m_recGameStruct.cellField, m_recGameStruct.waterSourcePositionQueueList);
            // continiue animation
            (Sender as TTimer).Enabled := true;
        end;
    end;

    procedure TFMain.formSetup();
    begin
        // inizialize
        m_recGameStruct.waterSourcePositionQueueList.firstNode := nil;
        checkedItem := NONE_BUTTON;
        oldButton := nil;

        // set default values
        m_recGameStruct.cellRowLength := DEFAULT_CELL_ROW_COUNT;
        m_recGameStruct.cellColumnLength := DEFAULT_CELL_COLUMN_COUNT;
        m_recGameStruct.wallPercentage := DEFAULT_WALL_PERCENTAGE;
        cellAnimationTickRate := DEFAULT_CELL_TICK_RATE;

        // for randomniss
        randomize;

        // ===CREATE PANEL-LAYOUT===
        // panel game area
        panelSetup(panelGameArea, FMain, 'panelGameArea');
        // panel gamefield
        panelSetup(panelGamefield, panelGameArea, 'panelGamefield');
        // gridpanel cellGrid
        createCellGrid(
            cellGrid,
            m_recGameStruct.waterSourcePositionQueueList,
            panelGamefield,
            m_recGameStruct.cellField,
            m_recGameStruct.cellRowLength,
            m_recGameStruct.cellColumnLength,
            onCellMouseDown,
            true
        );
        // panel right side area
        panelSetup(panelRightSideArea, FMain, 'panelSetup');
        // panel Right side info
        panelSetup(panelRightSideInfo, panelRightSideArea, 'panelRightSideInfo');
        createInfoButtons(
            panelrightSideInfo,
            pipeLidButton, pipeButton, pipeTSplitButton, pipeCurveButton,
            onItemChooseClick,
            gamemodeButton,
            onSideButtonClick
        );
        // panel Right side info
        panelSetup(panelButtons, panelRightSideArea, 'panelButtons');
        // buttons with panelButtons as parent
        createButtons(
            newGameButton,
            settingsButton,
            loadGameButton,
            saveGameButton,
            exitGameButton,
            panelButtons,
            onSideButtonClick
        );

        updateLayout();

        // creating fluid animation thread (timer)
        fluidTimer := TTimer.Create(FMain);
        with fluidTimer do
        begin
            Interval := cellAnimationTickRate;
            OnTimer := FMain.cellQueueHandler;
            Enabled := false;
        end;

        generateGame(
            m_recGameStruct.cellField,
            m_recGameStruct.cellRowLength, m_recGameStruct.cellColumnLength,
            m_recGameStruct.wallPercentage, m_recGameStruct.waterSourcePositionQueueList
        );

    end;

    procedure TFMain.FormCreate(Sender: TObject);
    begin
        formSetup();
    end;

    procedure TFMain.FormResize(Sender: TObject);
    begin
        updateLayout();
    end;

    procedure TFMain.FormCanResize(
        Sender: TObject;
        var NewWidth, NewHeight: Integer;
        var Resize: Boolean
    );
    begin
        NewHeight := round(MAIN_FORM_ASPECT_RATIO * NewWidth);
    end;

    procedure TFMain.enableSimulationMode(b: Boolean);
    begin
        FSettings.nbColumns.Enabled := b;
        FSettings.nbRows.Enabled := b;
        FSettings.nbwallPercentage.Enabled := b;

        newGameButton.Enabled := b;
        loadGameButton.Enabled := b;
        saveGameButton.Enabled := b;
    end;

    procedure TFMain.animationStart();
    begin
        isSimulating := true;
        enableSimulationMode(false);
        fluidTimer.Enabled := true;
    end;

    procedure TFMain.finalizeAnimation();
    begin
        isSimulating := false;
        enableSimulationMode(true);
    end;

end.
