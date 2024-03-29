﻿{
    file:       UMain.pas
    author:     John Lienau
    title:      Main unit of project Floodpipe
    version:    v1.0
    date:       03.08.2022
    copyright:  Copyright (c) 2022

    brief:      This unit contains the main form of the application
                and all the methods that are called by the form
}

unit UMain;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, System.UITypes,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,

    USettings,

    UProperties, UFunctions, UTypedefine, UCellFunctions, UFluid,
    UPositionFunctions, UGameGeneration, UFileHandler;

type
    TFMain = class(TForm)

        {
            On Resize the aspect ratio will be maintained

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

        {
            Setup after the FMain shows
            Panels, buttons and the game is setup here

            @param  IN      Sender: not used
        }
        procedure formSetup();

        {
            On Resize the aspect ratio will be maintained

            @param  IN      Sender: not used
        }
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

        {
            frees the m_recGameStruct.waterSourcePositionQueueList
        }
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
        {
            handles the click on the animate button

            @param  IN      Sender: the button
        }
        procedure onCellClick(Sender: TObject);

        {
            handles the click on the animate button

            @param  IN      Sender: the button
        }
        procedure onCellMouseDown(
            Sender: TObject;
            Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer
        );

        {
            handles the click on the animate button

            @param  IN      Sender: the button
        }
        procedure onGamemodeButtonClick(Sender: TObject);
        
        {
            opens a load menu
            when specific changes has been made a game restart will be made

            @param  IN      Sender: the button 
        }
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

        {
            sets the choseen item to the clicked button

            @param  IN      Sender: the clicked button
        }
        procedure onItemChooseClick(Sender: TObject);

    public
        // ---panels---
        m_panelGameArea: TPanel;
        m_panelRightSideArea: TPanel;
        m_panelRightSideInfo: TPanel;
        m_panelButtons: TPanel;
        m_panelGamefield: TPanel;

        // ---item buttons---
        m_btnPipeLidButton: TButton;
        m_btnPipeButton: TButton;
        m_btnPipeTSplitButton: TButton;
        m_btnPipeCurveButton: TButton;
        m_btnWallButton: TButton;
        m_btnWaterSourceButton: TButton;

        m_btnGamemodeButton: TButton;

        // ---side buttons---
        m_btnAnimate: TButton;
        m_btnNewGameButton: TButton;
        m_btnSettingsButton: TButton;
        m_btnLoadGameButton: TButton;
        m_btnSaveGameButton: TButton;
        m_btnExitGameButton: TButton;

        // ---gamefield---
        m_gridpanelCellGrid: TGridPanel;

    private
        {
            sets the visibility to the passed boolean of all Itembuttons

            @param  IN      b: passed boolean to set the visibility
        }
        procedure setItemButtonVisibility(b:boolean);
    end;

var
    FMain: TFMain;
    m_iCellAnimationTickRate: Integer;
    m_iTimerCount: Integer;
    m_fluidTimer: TTimer;
    m_bIsSimulating: Boolean;
    m_bIsEditorMode: boolean;
    m_eCheckedItem: TItemButton;
    m_btnOldButon: TButton;
    m_recGameStruct: TGameStruct;
    m_bNotSaved: Boolean;

implementation

    {$R *.dfm}

    procedure TFMain.onSideButtonClick(Sender: TObject);
    begin
        // check which button was clicked
        case TSideButton((Sender as TButton).tag) of
            GAMEMODE_BUTTON:
                onGamemodeButtonClick(Sender);

            ANIMATE_BUTTON:
               onNewButtonClick(Sender);

            GENERATE_NEW_FIELD_BUTTON:
            begin
                // ask if its intended to generate a new field
                if (MessageDlg(
                        'Do you want to generate a new field?',
                        mtConfirmation,
                        [mbYes, mbNo],
                        0
                    ) = mrYes) then
                begin
                    // ask for saveing the current field
                    if (m_bNotSaved) and 
                        (MessageDlg(
                            'Do you want to save the current field?',
                            mtConfirmation,
                            [mbYes, mbNo],
                            0
                        ) = mrYes) then
                        saveGame(m_recGameStruct, self, m_bNotSaved);
                
                    removeCellGrid(m_gridpanelCellGrid, m_recGameStruct.cellField);
                    createCellGrid(
                        m_gridpanelCellGrid,
                        m_recGameStruct.waterSourcePositionQueueList,
                        m_panelGamefield,
                        m_recGameStruct.cellField, m_recGameStruct.cellRowLength,
                        m_recGameStruct.cellColumnLength,
                        onCellMouseDown,
                        true
                    );
                    generateGame(
                        m_recGameStruct.cellField,
                        m_recGameStruct.cellRowLength, m_recGameStruct.cellColumnLength,
                        m_recGameStruct.wallPercentage,
                        m_recGameStruct.waterSourcePositionQueueList,
                        not m_bIsEditorMode
                    );

                    m_bNotSaved := true;
                end;
            end;

            SETTINGS_BUTTON: 
                onSettingsButtonClick(Sender);

            LOAD_BUTTON: loadGame(
                m_recGameStruct,
                self,
                m_panelGamefield,
                onCellMouseDown,
                m_gridpanelCellGrid,
                m_bNotSaved
            );

            SAVE_BUTTON: saveGame(m_recGameStruct, self, m_bNotSaved);

            EXIT_BUTTON:
                // ask if its intended to exit the game
                if (MessageDlg(
                    'Do you want to exit the game?',
                    mtConfirmation,
                    [mbYes, mbNo],
                    0
                ) = mrYes) then
                begin
                    // ask if its intended to save the game
                    if m_bNotSaved and (MessageDlg(
                        'Do you want to save the game?',
                        mtConfirmation,
                        [mbYes, mbNo],
                        0
                    ) = mrYes) then
                        saveGame(m_recGameStruct, self, m_bNotSaved);
                    
                    Application.Terminate;
                end;

            else; // nothing
        end;
    end;

    procedure TFMain.onItemChooseClick(Sender: TObject);
    begin
        if (m_btnOldButon <> nil) then
        begin
            // remove font style of old button
            m_btnOldButon.font.style := [];
        end;

        // when the same button is clicked again
        if (m_eCheckedItem = TItemButton((Sender as TButton).tag)) then
            m_eCheckedItem := NONE_BUTTON
        else // when not the same button
            m_eCheckedItem := TItemButton((Sender as TButton).tag);

        // set font style of new button
        case m_eCheckedItem of
            PIPE_LID_BUTTON,
            PIPE_BUTTON,
            PIPE_TSPLIT_BUTTON,
            PIPE_CURVE_BUTTON,
            WALL_BUTTON:
                (Sender as TButton).font.style := [fsBold];

            else; // nothing
        end;

        m_btnOldButon := (Sender as TButton);
    end;

    procedure TFMain.setItemButtonVisibility(b:boolean);
    begin
        m_btnPipeLidButton.visible := b;
        m_btnPipeButton.visible := b;
        m_btnPipeTSplitButton.visible := b;
        m_btnPipeCurveButton.visible := b;
        m_btnWallButton.visible := b;
        m_btnWaterSourceButton.visible := b;
    end;

    procedure TFMain.onGamemodeButtonClick(Sender: TObject);
    begin
        m_bIsEditorMode := not m_bIsEditorMode;

        // changing to editormode
        if (m_bIsEditorMode) then
        begin
            m_btnGamemodeButton.caption := 'Editor';
            setItemButtonVisibility(true);
        end
        else // m_bIsEditorMode == false
        begin
            m_btnGamemodeButton.caption := 'Playing';
            m_eCheckedItem := NONE_BUTTON;
            // remove font style of old button
            if (m_btnOldButon <> nil) then
                m_btnOldButon.font.style := [];
            setItemButtonVisibility(false);
        end;
    end;

    procedure TFMain.onNewButtonClick(Sender: TObject);
    begin
        // fixme no saving when loading is not possible.
        // // tempsave the current game and start the animation
        // saveGame(
        //     m_recGameStruct,
        //     self,
        //     m_bNotSaved,
        //     '~$tempAnimationSave',
        //     false,
        //     true
        // );
        animationStart();
    end;

    procedure TFMain.onSettingsButtonClick(Sender: TObject);
    begin
        case FSettings.ShowModal of
            mrOk:
            begin
                // settings übernehmen welche die simulation beeinflussen würde
                if (not m_bIsSimulating) then
                begin
                    // wenn die settings geändert wurden und die neue simulation geladen werden muss (z.B. neue größe)
                    // dann wird nach einer bestätigung gefragt
                    if getSettingsFromFSettings() and (MessageDlg(
                        'Do you want to generate a new gamefield with the new settings?',
                        mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
                    begin
                        // ask for saving the old game when it is not saved
                        if m_bNotSaved and (MessageDlg(
                            'Do you want to save the game?',
                            mtConfirmation,
                            [mbYes, mbNo],
                            0
                        ) = mrYes) then
                        begin
                            case saveGameToFile('Test', m_recGameStruct) of
                                FILE_ERROR_FILE_DOESNT_EXIST: showmessage('file doesnt exist');
                                FILE_ERROR_COULD_NOT_WRITE_TO_FILE: showmessage('could not write to file');
                                FILE_ERROR_NONE: m_bNotSaved := false;

                                else showmessage('unnamed error'); // should never happen
                            end;
                        end;

                        // remove old gamefield and create new one
                        removeCellGrid(m_gridpanelCellGrid, m_recGameStruct.cellField);
                        createCellGrid(
                            m_gridpanelCellGrid,
                            m_recGameStruct.waterSourcePositionQueueList,
                            m_panelGamefield,
                            m_recGameStruct.cellField, m_recGameStruct.cellRowLength,
                            m_recGameStruct.cellColumnLength,
                            onCellMouseDown,
                            true
                        );
                        generateGame(
                            m_recGameStruct.cellField,
                            m_recGameStruct.cellRowLength, m_recGameStruct.cellColumnLength,
                            m_recGameStruct.wallPercentage,
                            m_recGameStruct.waterSourcePositionQueueList,
                            not m_bIsEditorMode
                        );

                        m_bNotSaved := true;
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
        if not m_bIsSimulating then
        begin
            position := getPositionFromName(TImage(Sender).name);

            if m_bIsEditorMode then
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
        if not m_bIsSimulating then
        begin
            position := getPositionFromName(TImage(Sender).name);

            // check which item is checked
            case m_eCheckedItem of
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

            WATER_SOURCE_BUTTON:
            begin
                if not setWaterSource(
                    m_recGameStruct.cellField,
                    m_recGameStruct.waterSourcePositionQueueList,
                    position
                ) then
                    showmessage('You cant place a watersource there!');
            end;

            else // should never happen 
                showmessage('no such item');
            end;
        end;

        m_bNotSaved := true;
    end;

    procedure TFMain.updateLayout();
    begin
        // update positions
        panelRedraw(
            FMain.ClientWidth, FMain.ClientHeight,
            m_panelGameArea,
            m_panelGamefield,
            m_panelRightSideArea,
            m_panelRightSideInfo,
            m_panelButtons
        );
    end;

    procedure TFMain.cellQueueHandlerFinalize();
    begin
        finalizeAnimation();
        // todo show leaks

        // fixme here should be the loading of the old game struct from the temp file
        // but i dont know how to do that yet without having a bug.
    end;

    procedure TFMain.setFSettingsFromSettings();
    begin
        FSettings.nbRows.Value := m_recGameStruct.cellRowLength;
        FSettings.nbColumns.Value := m_recGameStruct.cellColumnLength;
        FSettings.nbAnimationTime.Value := m_iCellAnimationTickRate;
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
        m_iCellAnimationTickRate := round(FSettings.nbAnimationTime.Value);
        m_fluidTimer.interval := m_iCellAnimationTickRate;
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
        m_eCheckedItem := NONE_BUTTON;
        m_btnOldButon := nil;

        // set default values
        m_recGameStruct.cellRowLength := DEFAULT_CELL_ROW_COUNT;
        m_recGameStruct.cellColumnLength := DEFAULT_CELL_COLUMN_COUNT;
        m_recGameStruct.wallPercentage := DEFAULT_WALL_PERCENTAGE;
        m_iCellAnimationTickRate := DEFAULT_CELL_TICK_RATE;

        // for randomniss
        randomize;

        // ===CREATE PANEL-LAYOUT===
        // panel game area
        panelSetup(m_panelGameArea, FMain, 'm_panelGameArea');
        // panel gamefield
        panelSetup(m_panelGamefield, m_panelGameArea, 'm_panelGamefield');
        // gridpanel m_gridpanelCellGrid
        createCellGrid(
            m_gridpanelCellGrid,
            m_recGameStruct.waterSourcePositionQueueList,
            m_panelGamefield,
            m_recGameStruct.cellField,
            m_recGameStruct.cellRowLength,
            m_recGameStruct.cellColumnLength,
            onCellMouseDown,
            true
        );
        // panel right side area
        panelSetup(m_panelRightSideArea, FMain, 'panelSetup');
        // panel Right side info
        panelSetup(m_panelRightSideInfo, m_panelRightSideArea, 'm_panelRightSideInfo');
        createInfoButtons(
            m_panelRightSideInfo,

            // item buttons
            m_btnPipeLidButton,
            m_btnPipeButton,
            m_btnPipeTSplitButton,
            m_btnPipeCurveButton,
            m_btnWallButton,
            m_btnWaterSourceButton,

            onItemChooseClick,
            m_btnGamemodeButton,
            onSideButtonClick
        );
        // panel Right side info
        panelSetup(m_panelButtons, m_panelRightSideArea, 'm_panelButtons');
        // buttons with m_panelButtons as parent
        createButtons(
            m_btnNewGameButton,
            m_btnSettingsButton,
            m_btnNewGameButton,
            m_btnLoadGameButton,
            m_btnSaveGameButton,
            m_btnExitGameButton,
            m_panelButtons,
            onSideButtonClick
        );

        updateLayout();

        // creating fluid animation thread (timer)
        m_fluidTimer := TTimer.Create(FMain);
        with m_fluidTimer do
        begin
            Interval := m_iCellAnimationTickRate;
            OnTimer := FMain.cellQueueHandler;
            Enabled := false;
        end;

        generateGame(
            m_recGameStruct.cellField,
            m_recGameStruct.cellRowLength, m_recGameStruct.cellColumnLength,
            m_recGameStruct.wallPercentage, m_recGameStruct.waterSourcePositionQueueList,
            true
        );
        m_bNotSaved := true;
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
        // keep aspect ratio
        if NewWidth < NewHeight then
            NewWidth := round(NewHeight / MAIN_FORM_ASPECT_RATIO)
        else // NewWidth >= NewHeight
            NewHeight := round(MAIN_FORM_ASPECT_RATIO * NewWidth);
    end;

    procedure TFMain.enableSimulationMode(b: Boolean);
    begin
        FSettings.nbColumns.Enabled := b;
        FSettings.nbRows.Enabled := b;
        FSettings.nbwallPercentage.Enabled := b;

        // side buttons
        m_btnNewGameButton.Enabled := b;
        m_btnLoadGameButton.Enabled := b;
        m_btnSaveGameButton.Enabled := b;

        // all itemchoose buttons
        m_btnPipeLidButton.Enabled := b;
        m_btnPipeButton.Enabled := b;
        m_btnPipeTSplitButton.Enabled := b;
        m_btnPipeCurveButton.Enabled := b;
        m_btnWallButton.Enabled := b;
        m_btnWaterSourceButton.Enabled := b;
    end;

    procedure TFMain.animationStart();
    begin
        m_bIsSimulating := true;
        enableSimulationMode(false);
        m_fluidTimer.Enabled := true;
    end;

    procedure TFMain.finalizeAnimation();
    begin
        m_bIsSimulating := false;
        enableSimulationMode(true);
    end;

end.
