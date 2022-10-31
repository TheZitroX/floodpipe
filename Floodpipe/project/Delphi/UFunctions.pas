{
    file:       UFunctions.pas
    author:     John Lienau
    title:      Floodpipe functions
    version:    v1.0
    date:       30.07.2022
    copyright:  Copyright (c) 2022

    brief:      Mostly used functions by the main unit of Floodpipe
}

unit UFunctions;

interface

    uses 
        vcl.Forms, sysutils, vcl.extctrls, vcl.controls, system.classes, Vcl.StdCtrls,

        UTypedefine, UPixelfunctions, UProperties, UCellFunctions, UPositionFunctions;

    // public functions
    procedure panelSetup(
        var panel:TPanel;
        panelParent:TWinControl;
        panelName:string
    );
    procedure createCellGrid(
        var cellGrid:TGridPanel;
        panelParent:TWinControl;
        var cellField:TCellField;
        rowCount, columnCount:integer;
        onCellClick:TNotifyEvent
    );
    procedure removeCellGrid(
        var cellGrid:TGridPanel;
        panelParent:TWinControl;
        var cellField:TCellField
    );
    procedure panelRedraw(
        mainWidth, mainHeight:integer;
        var panelGameArea:TPanel;
        var panelGamefield:TPanel;
        var panelRightSideArea:TPanel;
        var panelRightSideInfo:TPanel;
        var panelButtons:TPanel
    );
    procedure createInfoButtons(
        var newParent:TPanel;
        var pipeLidButton:TButton;
        var pipeButton:TButton;
        var pipeTSplitButton:TButton;
        var pipeCurveButton:TButton;
        onItemChooseClick:TNotifyEvent;
        var gamemodeButton:TButton;
        onGamemodeButtonClick:TNotifyEvent
    );
    procedure createButtons(
        var b1:TButton;
        b1Procedure:TNotifyEvent;
        var b2:TButton;
        b2Procedure:TNotifyEvent;
        var b3:TButton;
        var b4:TButton;
        var b5:TButton;
        var newParent:TPanel
    );

implementation

    {
        Sets the position anad side length of a panel

        @param  panel the changed panel
                newTop the top position
                newLeft the left position
                newWidth the width
                newHeight the height
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

    {
        setup for the panel
        parent and name to variables
        and the caption to empty

        @param  panel the target
                panelParent the parent of target panel
                parentName the name of the target panel
    }
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


    {
        Creates a panelgrid with rowCount and columnCount dimentions,
        sets the cells and spaces them evently out

        IN/OUT:     cellGrid
                    cellField field of all cells

        IN:         panelParent the parent of cellGrid
                    rowCount and columnCount the dimentions of the field
                    onCellClick the clickevent of the cells
    }
    procedure createCellGrid(
        var cellGrid:TGridPanel;
        panelParent:TWinControl;
        var cellField:TCellField;
        rowCount, columnCount:integer;
        onCellClick:TNotifyEvent);
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
            cellGrid,
            rowCount,
            columnCount,
            onCellClick
        );

        cellGrid.RowCollection.EndUpdate;
        cellGrid.ColumnCollection.EndUpdate;
    end;

    procedure removeCellGrid(
        var cellGrid:TGridPanel;
        panelParent:TWinControl;
        var cellField:TCellField
    );
    var i, j:integer;
    begin
        // remove each cellfield
        for i := 0 to length(cellField) - 1 do
            for j := 0 to length(cellField[0]) - 1 do
            begin
                cellField[i, j].image.picture := nil;
                cellField[i, j].image.Free;
                delPositionList(cellField[i,j].openings);
            end;
        cellGrid.Free;
    end;

    {
        Gives each panel its position and size,
        relativ to the width and height of the FMain size

        @param  mainWidth: width of FMain
                mainHeight: newHeight of FMain
                panelGameArea: the Gamearea panel
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
        tempHeight := (mainHeight * 80) div 100; // 80% of Height
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
        @brief  Creates a Button with passed positions, names and onclick fucntioncall

        @param  button as the Changed button
                topPos and leftPos as integer
                buttonName, buttonCaption as string
                functionPointer as TNotifyEvent
    }
    procedure createOptionButton(
        var button:TButton;
        var newParent:TPanel;
        buttonName, buttonCaption:string;
        functionPointer:TNotifyEvent;
        newAlign:TAlign
    );
    begin
        button := TButton.Create(newParent);
        with button do begin
            Parent := newParent;
            Name := buttonName;
            Caption := buttonCaption;
            OnClick := functionPointer;
            Align := newAlign;
        end;
    end;

    procedure createInfoButtons(
        var newParent:TPanel;
        var pipeLidButton:TButton;
        var pipeButton:TButton;
        var pipeTSplitButton:TButton;
        var pipeCurveButton:TButton;
        onItemChooseClick:TNotifyEvent;
        var gamemodeButton:TButton;
        onGamemodeButtonClick:TNotifyEvent
    );
    begin
            // PIPE_LID,
        createOptionButton(
            pipeLidButton,
            newParent,
            'pipeLidButton',
            'Lid',
            onItemChooseClick,
            alTop
        );
        pipeLidButton.tag := integer(PIPE_LID_BUTTON);
        pipeLidButton.visible := false;
        createOptionButton(
            pipeButton,
            newParent,
            'pipeButton',
            'Pipe',
            onItemChooseClick,
            alTop
        );
        pipeButton.tag := integer(PIPE_BUTTON);
        pipeButton.visible := false;
        createOptionButton(
            pipeTSplitButton,
            newParent,
            'pipeTSplitButton',
            'T-Split',
            onItemChooseClick,
            alTop
        );
        pipeTSplitButton.tag := integer(PIPE_TSPLIT_BUTTON);
        pipeTSplitButton.visible := false;
        createOptionButton(
            pipeCurveButton,
            newParent,
            'pipeCurveButton',
            'Curve',
            onItemChooseClick,
            alTop
        );
        pipeCurveButton.tag := integer(PIPE_CURVE_BUTTON);
        pipeCurveButton.visible := false;


        createOptionButton(
            gamemodeButton,
            newParent,
            'gamemodeButton',
            'Playing',
            onGamemodeButtonClick,
            alBottom
        );
    end;

    procedure createButtons(
        var b1:TButton;
        b1Procedure:TNotifyEvent;
        var b2:TButton;
        b2Procedure:TNotifyEvent;
        var b3:TButton;
        var b4:TButton;
        var b5:TButton;
        var newParent:TPanel
    );
    begin
        createOptionButton(
            b1,
            newParent,
            'newGameButton',
            'New',
            b1Procedure,
            TAlign(alTop)
        );
        createOptionButton(
            b2,
            newParent,
            'settingsButton',
            'Settings',
            b2Procedure,
            TAlign(alTop)
        );
        createOptionButton(
            b3,
            newParent,
            'loadGameButton',
            'Load',
            nil,
            TAlign(alTop)
        );
        createOptionButton(
            b4,
            newParent,
            'saveGameButton',
            'Save',
            nil, 
            TAlign(alTop)
        );
        createOptionButton(
            b5,
            newParent,
            'quitGameButton',
            'Quit',
            nil,
            TAlign(alTop)
        );
    end;
end.