{
    file:       UCellFunctions.pas
    author:     John Lienau
    date:       05.08.2022
    version:    v1.0
    copyright:  Copyright (c) 2022

    brief:      provides simple operation for cells
}

unit UCellFunctions;

interface
    uses
        vcl.Forms, sysutils, vcl.extctrls, vcl.controls, system.classes,

        UTypedefine, UPixelfunctions, UProperties;

    procedure cellSetup(
        var cell:TCell;
        newParent:TWinControl;
        newName:string);

    procedure createCells(
        var cellField:TCellField;
        newParent:TWinControl;
        rowCount, columnCount:integer;
        onCellClick:TNotifyEvent);

    procedure rotateCellClockwise(var cell:TCell);

    function getPositionFromName(name:string):TPosition;

implementation

    {
        Creates a cell with name and parant
        @param  cell as target
                newParent the parant of target
                newName the name of target
    }
    procedure cellSetup(
        var cell:TCell;
        newParent:TWinControl;
        newName:string);
    begin
        cell.image := TImage.Create(newParent);
        try
            with cell.image do
            begin
                Parent := newParent;
                Name := newName;
                Stretch := true; // to fill the whole cell
            end;
        except
            // todo fehler beim schreiben?
            // muss das überall so?
        end;
    end;

    procedure setCellToItem(
        var cell:TCell;
        newCellType:TCellType;
        newCellItem:TCellItem;
        newCellContent:TCellContent;
        newCellRotation:TCellRotation);
    begin
        with cell do
        begin
            cellType := newCellType;
            cellItem := newCellItem;
            cellContent := newCellContent;
            cellRotation := newCellRotation;
        end;
        loadPictureFromBitmap(cell);
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
        rowCount, columnCount:integer;
        onCellClick:TNotifyEvent);
    var
        i, j:integer;
    begin
        // create the array-field with the needed length
        setLength(cellField, columnCount, rowCount);
        // create cells
        for j := 0 to columnCount - 1 do
            for i := 0 to rowCount - 1 do
            begin
                cellSetup(
                    cellField[i][j],
                    newParent,
                    'cellx' + inttostr(i) + 'y' + inttostr(j)
                );
                cellField[i][j].image.Align := alClient;
                setCellToItem(
                    cellField[i][j],
                    // debug just random types for testing
                    TCellType.TYPE_PIPE,
                    TCellItem(Random(Succ(Ord(High(TCellItem)))) + 1),
                    TCellContent(Random(Succ(Ord(High(TCellContent))))),
                    TCellRotation(Random(Succ(Ord(High(TCellRotation)))))
                );
                cellField[i][j].image.OnClick := onCellClick;
            end;
    end;

    procedure rotateCellClockwise(var cell:TCell);
    begin
        // todo rotation
    end;

    function getPositionFromName(name:string):TPosition;
        {
            @brief  to get the x-integer-value of the Cell-name
                    (exmp.) name = c0x1y4
                            -> x = 1

            @param name is the Cell-name
            @return x as integer
        }
        function getXFromCellName(name:string):integer;
        var
            posX, posY:integer;
        begin
            posX := pos('x', name) + 1;
            posY := pos('y', name);
            getXFromCellName := strtoint(copy(name, posX, posY - posX));
        end;
        {
            @brief  to get the y-integer-value of the Cell-name
                    (exmp.) name = c0x1y4
                            -> y = 4

            @param name is the Cell-name
            @return y as integer
        }
        function getYFromCellName(name:string):integer;
        var
            posY:integer;
        begin
            posY := pos('y', name) + 1;
            getYFromCellName := strtoint(copy(name, posY));
        end;

    var
        position:TPosition;
    begin
        position.x := getXFromCellName(name);
        position.y := getYFromCellName(name);
        getPositionFromName := position;
    end;
end.