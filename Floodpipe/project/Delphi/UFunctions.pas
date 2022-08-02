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
    procedure createCellGrid(
        var cellGrid:TGridPanel;
        panelParent:TWinControl;
        cellField:TCellField;
        rowCount, columnCount:integer);
    procedure panelRedraw(
        mainWidth, mainHeight:integer;
        var panelGameArea:TPanel;
        var panelGamefield:TPanel;
        var panelRightSideArea:TPanel;
        var panelRightSideInfo:TPanel;
        var panelButtons:TPanel;
        var cellField:TCellField;
        rowCount, columnCount:integer);
    
    procedure createCells(
        var cellField:TCellField;
        newParent:TWinControl;
        rowCount, columnCount:integer);

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
            creates a field (rows * columns) of TCellField

            @param  cellField the field of TPanel
                    newParent the parent of cellField
                    rowCount the row-count
                    columnCount the column-count
        }
        procedure createCells(
            var cellField:TCellField;
            newParent:TWinControl;
            rowCount, columnCount:integer);
        var
            i, j,
            cellSideLength:integer;
        begin
            // create the array-field with the needed length
            setLength(cellField, rowCount, columnCount);
            // create cells
            for i := 0 to rowCount - 1 do
                for j := 0 to columnCount - 1 do
                begin
                    panelSetup(
                        cellField[i][j],
                        newParent,
                        'cellx' + inttostr(i) + 'y' + inttostr(j)
                    );
                    cellField[i][j].Align := alClient;
                end;
        end;

        procedure createCellGrid(
            var cellGrid:TGridPanel;
            panelParent:TWinControl;
            cellField:TCellField;
            rowCount, columnCount:integer);
        var
            i:integer;
            testCell:TPanel;
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
                columnCount
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
                    cellField: array with cells (TCellField)
                    rowCount: the cell row count
                    columnCount: the column count of cells
        }
        procedure panelRedraw(
            mainWidth, mainHeight:integer;
            var panelGameArea:TPanel;
            var panelGamefield:TPanel;
            var panelRightSideArea:TPanel;
            var panelRightSideInfo:TPanel;
            var panelButtons:TPanel;
            var cellField:TCellField;
            rowCount, columnCount:integer);

            var
                i, j, tempHeight, 
                cellSideLength, cellFirstTopPos, cellFirstLeftPos,
                cellXWithOffset, cellYWithOffset:integer;
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


                // cells
                // calculates the sideLength of cells
                if (rowCount > columnCount) then begin
                    cellSideLength := round(panelGamefield.Width / rowCount);
                    // cellFirstTopPos := 0;
                    // cellFirstLeftPos := (panelGamefield.Width - (cellSideLength * columnCount)) div 2;
                end else begin
                    cellSideLength := round(panelGamefield.Width / columnCount);
                    // cellFirstTopPos := (panelGamefield.Height - (cellSideLength * rowCount)) div 2;
                    // cellFirstLeftPos := 0;
                end;
                // cellXWithOffset := cellSideLength + cellFirstTopPos;
                // cellYWithOffset := cellSideLength + cellFirstLeftPos;

                // for each cell in cellField
                for i := 0 to rowCount - 1 do
                    for j := 0 to columnCount - 1 do
                    begin
                        // cellField[i][j].Width := cellSideLength;
                        // cellField[i][j].Height := cellSideLength;

                        // setDimentions(
                        //     cellField[i][j],
                        //     i * cellXWithOffset,
                        //     j * cellYWithOffset,
                        //     cellSideLength,
                        //     cellSideLength
                        // );
                    end;
            end;

    end.