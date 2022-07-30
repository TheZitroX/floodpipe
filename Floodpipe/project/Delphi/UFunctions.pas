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
        vcl.Forms, sysutils, vcl.extctrls, vcl.controls,

        UTypedefine;

    // public functions
    procedure panelSetup(
        var panel:TPanel;
        panelParent:TWinControl;
        panelName:string);
    procedure panelRedraw(
        mainWidth, mainHeight:integer;
        var panelGameArea:TPanel;
        var panelGamefield:TPanel;
        var panelRightSideArea:TPanel;
        var panelRightSideInfo:TPanel;
        var panelButtons:TPanel;
        var cellField:TCellField;
        cellRowLength, cellColumnLength:integer);
    
    procedure createCells(
        var cellField:TCellField;
        panelGamefield:TPanel;
        cellRowLength:integer;
        cellColumnLength:integer);

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
            Gives each panel its position and size,
            relativ to the width and height of the FMain size

            @param  mainWidth: width of FMain
                    mainHeight: newHeight of FMain
                    panelGameArea: the Gamearea panel
                    panelGamefield: the field for the cells
                    panelRightsideArea: the panel on the right side
                    panelRightSideInfo: the panel with info text
                    panelButtons: the panel on the right side with buttons
                    cellField: array with cells (TCellField)
                    cellRowLength: the cell row count
                    cellColumnLength: the column count of cells
        }
        procedure panelRedraw(
            mainWidth, mainHeight:integer;
            var panelGameArea:TPanel;
            var panelGamefield:TPanel;
            var panelRightSideArea:TPanel;
            var panelRightSideInfo:TPanel;
            var panelButtons:TPanel;
            var cellField:TCellField;
            cellRowLength, cellColumnLength:integer);

            var
                i, j, tempHeight, cellSideLength, cellFirstTopPos, cellFirstLeftPos:integer;
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

                // cells
                // calculates the sideLength of cells
                if (cellRowLength > cellColumnLength) then begin
                    cellSideLength := round(panelGamefield.Width / cellRowLength);
                    cellFirstTopPos := 0;
                    cellFirstLeftPos := (panelGamefield.Width - (cellSideLength * cellColumnLength)) div 2;
                end else begin
                    cellSideLength := round(panelGamefield.Width / cellColumnLength);
                    cellFirstTopPos := (panelGamefield.Height - (cellSideLength * cellRowLength)) div 2;
                    cellFirstLeftPos := 0;
                end;

                // for each cell in cellField
                for i := 0 to cellRowLength - 1 do
                    for j := 0 to cellColumnLength - 1 do
                        setDimentions(
                            cellField[i][j],
                            i * cellSideLength + cellFirstTopPos,
                            j * cellSideLength + cellFirstLeftPos,
                            cellSideLength,
                            cellSideLength
                        );
            end;

        {
            creates a field (rows * columns) of TCellField

            @param  cellField the field of TPanel
                    panelGamefield the parent of cellField
                    cellRowLength the row-count
                    cellColumnLength the column-count
        }
        procedure createCells(
            var cellField:TCellField;
            panelGamefield:TPanel;
            cellRowLength:integer;
            cellColumnLength:integer);

            var
                i, j:integer;

            begin
                // create the array-field with the needed length
                setLength(cellField, cellRowLength, cellColumnLength);
                // create cells
                for i := 0 to cellRowLength - 1 do
                    for j := 0 to cellColumnLength - 1 do
                        panelSetup(
                            cellField[i][j],
                            panelGamefield,
                            'cellx' + inttostr(i) + 'y' + inttostr(j)
                        );
            end;

    end.