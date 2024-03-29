{
    file:       UFunctions.pas
    author:     John Lienau
    title:      Floodpipe functions
    version:    v1.0
    date:       30.07.2022
    copyright:  Copyright (c) 2022

    brief:      This file contains all functions that are used in the main form
                and are not directly related to the game logic
}

unit UFunctions;

interface

    uses 
        vcl.Forms, sysutils, vcl.extctrls, vcl.controls, system.classes, Vcl.StdCtrls,

        UTypedefine, UPixelfunctions, UProperties, UCellFunctions, UPositionFunctions;

    {
        setup for the panel
        parent and name to variables
        and the caption to empty

        @param  IN/OUT  panel: the target

                IN      panelParent: the parent of target panel
                        parentName: the name of the target panel
    }
    procedure panelSetup(
        var panel:TPanel;
        panelParent:TWinControl;
        panelName:string
    );

    {
        Creates a panelgrid with rowCount and columnCount dimentions,
        sets the cells and spaces them evently out

        @param  IN/OUT:     cellGrid
                            waterSourcePositionQueueList: with water sources
                            cellField: field of all cells

                IN:         panelParent: the parent of cellGrid
                            rowCount: and columnCount: the dimentions of the field
                            onCellClick: the clickevent of the cells
                            overrideTypes: when true, all types will be overriden to TYPE_NONE
    }
    procedure createCellGrid(
        var cellGrid:TGridPanel;
        var waterSourcePositionQueueList:TPositionList;
        panelParent:TWinControl;
        var cellField:TCellField;
        rowCount, columnCount:integer;
        onCellClick:TMouseEvent;
        overrideTypes:boolean
    );

    {
        Clears all cells of the cellField and removed its allocation 

        @param  IN/OUT  cellGrid the field -> nil
                        cellField all cells -> nil
    }
    procedure removeCellGrid(
        var cellGrid:TGridPanel;
        var cellField:TCellField
    );

    {
        Gives each panel its position and size,
        relativ to the width and height of the FMain size

        @param  IN      mainWidth: width of FMain
                        mainHeight: newHeight of FMain

                IN/OUT  panelGameArea: the Gamearea panel
                        panelGamefield: the field for the cells
                        panelRightsideArea: the panel on the right side
                        panelRightSideInfo: the panel with info text
                        panelButtons: the panel on the right side with buttons
    }
    procedure panelRedraw(
        mainWidth, mainHeight:integer;
        var panelGameArea:TPanel;
        var panelGamefield:TPanel;
        var panelRightSideArea:TPanel;
        var panelRightSideInfo:TPanel;
        var panelButtons:TPanel
    );

    {
        Creates all side buttons of the main form

        @param  IN/OUT  newParent the new parant of them
                        all buttons:    pipeLidButton,
                                        pipeButton,
                                        pipeTSplitButton,
                                        pipeCurveButton,
                                        wallButton,
                                        waterSourceButton
                                        gamemodeButton

                IN      onItemChoseClick: eventPointer when button clicked
                        onGamemodeButtonClick: when the gamemode Button has been clicked
    }
    procedure createInfoButtons(
        var newParent:TPanel;

        var pipeLidButton:TButton;
        var pipeButton:TButton;
        var pipeTSplitButton:TButton;
        var pipeCurveButton:TButton;
        var wallButton:TButton;
        var waterSourceButton:TButton;
        
        onItemChooseClick:TNotifyEvent;
        var gamemodeButton:TButton;
        onGamemodeButtonClick:TNotifyEvent
    );
    
    {
        Creates all side Buttons for saving and loading ect.

        @param  IN/OUT  btnAnimate: for starting animation
                        btnSettings: is the Settings button
                        btnNewGame: for generating a new gamefield
                        btnLoad: is the Load button for loading game from file
                        btnSave: is the Save button
                        btnExit: is the quit button

                IN      btnAnimateProcedure
                        btnSettingsProcedure
    }
    procedure createButtons(
        var btnAnimate:TButton;
        var btnSettings:TButton;
        var btnNewGame:TButton;
        var btnLoad:TButton;
        var btnSave:TButton;
        var btnExit:TButton;
        var newParent:TPanel;
        onClickFunction:TNotifyEvent
    );

implementation

    {
        Sets the position anad side length of a panel

        @param  IN      panel: the changed panel
                        newTop: the top position
                        newLeft: the left position
                        newWidth: the width
                        newHeight: the height
    }
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

    procedure panelSetup(
        var panel:TPanel;
        panelParent:TWinControl;
        panelName:string);
        begin
            panel := TPanel.Create(panelParent);
            with panel do
            begin
                Parent := panelParent;
                Name := panelName;
                caption := '';
            end;
        end;

    procedure createCellGrid(
        var cellGrid:TGridPanel;
        var waterSourcePositionQueueList:TPositionList;
        panelParent:TWinControl;
        var cellField:TCellField;
        rowCount, columnCount:integer;
        onCellClick:TMouseEvent;
        overrideTypes:boolean
    );
    var
        i:integer;
    begin
        cellGrid := TGridPanel.Create(panelParent);
        cellGrid.parent := panelParent;
        cellGrid.Align := alClient;

        cellGrid.RowCollection.BeginUpdate;
        cellGrid.ColumnCollection.BeginUpdate;
        // info: cannot clear if there are controls
        // clear any Controls
        for i := 0 to cellGrid.ControlCount - 1 do
            cellGrid.Controls[0].Free;
        cellGrid.RowCollection.Clear;
        cellGrid.ColumnCollection.Clear;

        // for every row
        for i := 0 to rowCount - 1 do
            with cellGrid.RowCollection.Add do
            begin
                SizeStyle := ssPercent;
                Value := 100 / rowCount; // each cell is evently spaced out
            end;
        // for every column
        for i := 0 to columnCount - 1 do
            with cellGrid.ColumnCollection.Add do
            begin
                SizeStyle := ssPercent;
                Value := 100 / columnCount; // each cell is evently spaced out
            end;

        // creation of cells
        createCells(
            cellField,
            waterSourcePositionQueueList,
            cellGrid,
            rowCount,
            columnCount,
            onCellClick,
            overrideTypes
        );

        cellGrid.RowCollection.EndUpdate;
        cellGrid.ColumnCollection.EndUpdate;
    end;

    procedure removeCellGrid(
        var cellGrid:TGridPanel;
        var cellField:TCellField
    );
    var i, j:integer;
    begin
        // remove each cellfield
        for i := 0 to length(cellField) - 1 do
        begin
            for j := 0 to length(cellField[0]) - 1 do
            begin
                // clear mamory
                cellField[i, j].image.picture := nil;
                cellField[i, j].image.Free;
                cellField[i, j].image := nil;
                delPositionList(cellField[i,j].openings);
            end;
            setlength(cellField[i], 0);
        end;
        setlength(cellField, 0);
        cellField := nil;
        cellGrid.Free;
        cellGrid := nil;
    end;

    procedure panelRedraw(
        mainWidth, mainHeight:integer;
        var panelGameArea:TPanel;
        var panelGamefield:TPanel;
        var panelRightSideArea:TPanel;
        var panelRightSideInfo:TPanel;
        var panelButtons:TPanel
    );
    var
        tempHeight:integer;
    begin
        // panelGameArea
        setDimentions(
            panelGameArea,
            0, 0, // pos(0, 0)
            (mainWidth * 80) div 100, // 80% of the Width
            mainHeight
        );
        // panelGamefield
        tempHeight := mainHeight; // 100% of Height
        setDimentions(
            panelGamefield,
            panelGameArea.Height - tempHeight, // height of panelGamearea - height of panelGamefield
            (panelGameArea.Width - tempHeight) div 2, // (width of panelGamearea - height of panelGamefield) / 2
            tempHeight,
            tempHeight
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
            0, // top-
            0, // left corner
            panelRightSideArea.Width,
            (panelRightSideArea.Height * 50) div 100 // 50% height of panelRightSideArea
        );
        // panelRightSideInfo
        setDimentions(
            panelButtons,
            (panelRightSideArea.Height * 50) div 100, // 50% height of panelRightSideArea
            0,
            panelRightSideArea.Width,
            (panelRightSideArea.Height * 50) div 100 // 50% height of panelRightSideArea
        );
    end;

    {
        @brief  Creates a Button with passed positions, names and onclick fucntioncall

        @param  IN/OUT  button as the Changed button
                        newParent
                
                IN      topPos and leftPos as integer
                        buttonName, buttonCaption as string
                        functionPointer as TNotifyEvent
    }
    procedure createOptionButton(
        var button:TButton;
        var newParent:TPanel;
        buttonName, buttonCaption:string;
        functionPointer:TNotifyEvent;
        newAlign:TAlign;
        id:integer
    );
    begin
        button := TButton.Create(newParent);
        with button do begin
            Parent := newParent;
            Name := buttonName;
            Caption := buttonCaption;
            OnClick := functionPointer;
            Align := newAlign;
            Tag := id;
        end;
    end;

    procedure createInfoButtons(
        var newParent:TPanel;

        var pipeLidButton:TButton;
        var pipeButton:TButton;
        var pipeTSplitButton:TButton;
        var pipeCurveButton:TButton;
        var wallButton:TButton;
        var waterSourceButton:TButton;
        
        onItemChooseClick:TNotifyEvent;
        var gamemodeButton:TButton;
        onGamemodeButtonClick:TNotifyEvent
    );
    begin
        createOptionButton(
            pipeLidButton,
            newParent,
            'pipeLidButton',
            'Lid',
            onItemChooseClick,
            alTop,
            integer(PIPE_LID_BUTTON)
        );
        pipeLidButton.visible := false;

        createOptionButton(
            pipeButton,
            newParent,
            'pipeButton',
            'Pipe',
            onItemChooseClick,
            alTop,
            integer(PIPE_BUTTON)
        );
        pipeButton.visible := false;

        createOptionButton(
            pipeTSplitButton,
            newParent,
            'pipeTSplitButton',
            'T-Split',
            onItemChooseClick,
            alTop,
            integer(PIPE_TSPLIT_BUTTON)
        );
        pipeTSplitButton.visible := false;

        createOptionButton(
            pipeCurveButton,
            newParent,
            'pipeCurveButton',
            'Curve',
            onItemChooseClick,
            alTop,
            integer(PIPE_CURVE_BUTTON)
        );
        pipeCurveButton.visible := false;

        createOptionButton(
            wallButton,
            newParent,
            'wallButton',
            'Wall',
            onItemChooseClick,
            alTop,
            integer(WALL_BUTTON)
        );
        wallButton.visible := false;

        createOptionButton(
            waterSourceButton,
            newParent,
            'waterSourceButton',
            'Watersource',
            onItemChooseClick,
            alTop,
            integer(WATER_SOURCE_BUTTON)
        );
        waterSourceButton.visible := false;

        createOptionButton(
            gamemodeButton,
            newParent,
            'gamemodeButton',
            'Playing',
            onGamemodeButtonClick,
            alBottom,
            integer(GAMEMODE_BUTTON)
        );
    end;

    procedure createButtons(
        var btnAnimate:TButton;
        var btnSettings:TButton;
        var btnNewGame:TButton;
        var btnLoad:TButton;
        var btnSave:TButton;
        var btnExit:TButton;
        var newParent:TPanel;
        onClickFunction:TNotifyEvent
    );
    begin
        createOptionButton(
            btnAnimate,
            newParent,
            'animateButton',
            'Animate',
            onClickFunction,
            TAlign(alBottom),
            integer(ANIMATE_BUTTON)
        );
        createOptionButton(
            btnNewGame,
            newParent,
            'newGameButton',
            'Generate New Field',
            onClickFunction,
            TAlign(alBottom),
            integer(GENERATE_NEW_FIELD_BUTTON)
        );
        createOptionButton(
            btnSettings,
            newParent,
            'settingsButton',
            'Settings',
            onClickFunction,
            TAlign(alBottom),
            integer(SETTINGS_BUTTON)
        );
        createOptionButton(
            btnLoad,
            newParent,
            'loadGameButton',
            'Load',
            onClickFunction,
            TAlign(alBottom),
            integer(LOAD_BUTTON)
        );
        createOptionButton(
            btnSave,
            newParent,
            'saveGameButton',
            'Save',
            onClickFunction, 
            TAlign(alBottom),
            integer(SAVE_BUTTON)
        );
        createOptionButton(
            btnExit,
            newParent,
            'quitGameButton',
            'Quit',
            onClickFunction,
            TAlign(alBottom),
            integer(EXIT_BUTTON)
        );
    end;
end.