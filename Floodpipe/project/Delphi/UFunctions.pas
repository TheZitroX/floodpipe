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

        UTypedefine, UPixelfunctions, UProperties, UCellFunctions;

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
    procedure panelRedraw(
        mainWidth, mainHeight:integer;
        var panelGameArea:TPanel;
        var panelGamefield:TPanel;
        var panelRightSideArea:TPanel;
        var panelRightSideInfo:TPanel;
        var panelButtons:TPanel
    );
    procedure createButtons(
        var b1,b2,b3,b4:TButton;
        parent:TWinControl
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
        var panelButtons:TPanel);

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

    procedure createButtons(
        var b1,b2,b3,b4:TButton;
        parent:TWinControl
    );
    const
        OPTION_BUTTON_HEIGHT = 50;
        OPTION_BUTTON_WIDTH = 100;
    var
        i, topPosition, leftPosition:integer;

        {
            @brief  Creates a Button with passed positions, names and onclick fucntioncall

            @param  button as the Changed button
                    topPos and leftPos as integer
                    buttonName, buttonCaption as string
                    functionPointer as TNotifyEvent
        }
        procedure createOptionButton(
            var button:TButton;
            parent:TWinControl;
            topPos, leftPos:integer;
            buttonName, buttonCaption:string;
            functionPointer:TNotifyEvent
        );
        begin
            button := TButton.Create(parent);
            with button do begin
                Parent := parent;
                Top := topPos;
                Left := leftPos;
                Width := OPTION_BUTTON_WIDTH;
                Height := OPTION_BUTTON_HEIGHT;
                Name := buttonName;
                Caption := buttonCaption;
                OnClick := functionPointer;
            end;
        end;

    begin
        // leftPosition is calculated to get the buttons in the center of optionButtonsPanel
        leftPosition := 0;//(parent.Width div 2) - (OPTION_BUTTON_WIDTH div 2);
        // for the spacing on topPosition
        for i := 0 to 3 do begin
            // topPosition is calculated to get the buttonspacing
            topPosition := 0;//(OPTION_BUTTON_HEIGHT div 3) * (i + 1) + (OPTION_BUTTON_HEIGHT * i);
            case i of
                0:  createOptionButton(
                        b1,
                        parent,
                        topPosition,
                        leftPosition,
                        'newGameButton',
                        'New',
                        nil
                    );
                1:  createOptionButton(
                        b2,
                        parent,
                        topPosition,
                        leftPosition,
                        'loadGameButton',
                        'Load',
                        nil
                    );
                2:  createOptionButton(
                        b3,
                        parent,
                        topPosition,
                        leftPosition,
                        'saveGameButton',
                        'Save',
                        nil 
                    );
                3:  createOptionButton(
                        b4,
                        parent,
                        topPosition,
                        leftPosition,
                        'quitGameButton',
                        'Quit',
                        nil
                    );
            end;
        end;
    end;

end.