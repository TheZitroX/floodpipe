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

        UTypedefine, UPixelfunctions, UProperties, UPositionFunctions;

    procedure cellSetup(
        var cell:TCell;
        newParent:TWinControl;
        newName:string
    );
    procedure createCells(
        var cellField:TCellField;
        newParent:TWinControl;
        rowCount, columnCount:integer;
        onCellClick:TNotifyEvent
    );
    procedure rotateCellClockwise(var cell:TCell);
    function getPositionFromName(name:string):TPosition;
    function cellOpeningsToString(cell:TCell):string;
    procedure setCellToItem(
        var cell:TCell;
        newCellType:TCellType;
        newCellItem:TCellItem;
        newCellContent:TCellContent;
        newCellRotation:TCellRotation
    );
    procedure fillCellWithContent(var cell:TCell; content:TCellContent);
    function isCellEmpty(cell:TCell):boolean;
    function getCellFromPosition(cellField:TCellField; position:TPosition):TCell;
    function isCellConnected(cell:TCell; position:TPosition):boolean;

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

    {
        sets a cell to the passed types

        @param  IN/OUT: the target cell
                IN:     celltype, cellitem,
                        cellContent and cellRotation
    }
    procedure setCellToItem(
        var cell:TCell;
        newCellType:TCellType;
        newCellItem:TCellItem;
        newCellContent:TCellContent;
        newCellRotation:TCellRotation
    );
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
        sets the openings from type and rotation of a cell

        @param  IN/OUT: target cell
    }
    procedure setOpeningsFromRotation(var cell:TCell);
    begin
        with cell do begin
            case cellType of
                TYPE_WALL:;// do nothing
                TYPE_PIPE:  case cellItem of
                                PIPE: begin
                                    appendPosition(openings, 1, 0);
                                    appendPosition(openings, -1, 0);
                                end;
                                PIPE_LID: appendPosition(openings, 1, 0);
                                PIPE_TSPLIT: begin;
                                    appendPosition(openings, 1, 0);
                                    appendPosition(openings, 0, 1);
                                    appendPosition(openings, 0, -1);
                                end;
                                PIPE_CURVES: begin;
                                    appendPosition(openings, -1, 0);
                                    appendPosition(openings, 0, 1);
                                end;
                            end;
                else assert(true, 'ERROR cant set openings from this type');
            end;
            rotatePositionsByCellRotation(cell);
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
        rowCount, columnCount:integer;
        onCellClick:TNotifyEvent);
    var
        i, j:integer;
    begin
        // create the array-field with the needed length
        setLength(cellField, columnCount, rowCount);
        // create cells
        for j := 0 to rowCount - 1 do
            for i := 0 to columnCount - 1 do begin
                cellSetup(
                    cellField[i, j],
                    newParent,
                    'cellx' + inttostr(i) + 'y' + inttostr(j)
                );
                cellField[i][j].image.Align := alClient;
                setCellToItem(
                    cellField[i, j],
                    // debug just random types for testing
                    TCellType.TYPE_PIPE,
                    TCellItem(Random(Succ(Ord(High(TCellItem))))),
                    // TCellItem.PIPE,
                    // TCellContent(Random(Succ(Ord(High(TCellContent))))),
                    TCellContent.CONTENT_EMPTY,
                    TCellRotation(Random(Succ(Ord(High(TCellRotation)))))
                    // TCellRotation.NONE
                );
                cellField[i, j].openings.firstNode := nil;
                setOpeningsFromRotation(cellField[i, j]);
                cellField[i][j].image.OnClick := onCellClick;
            end;
    end;

    {
        @brief  increments the rotational state of a cell
                and updates the bitmap of it
        
        @param  IN/OUT: TCell the rotated cell
    }
    procedure rotateCellClockwise(var cell:TCell);
    begin
        if (cell.cellRotation = high(TCellRotation)) then
            cell.cellRotation := low(TCellRotation)
        else inc(cell.cellRotation);
        loadPictureFromBitmap(cell);
        rotatePositions(cell);
    end;

    {
        @brief  gets the position of a cell name

        @param  IN:     string the cell name
                OUT:    TPosition with the x and y values of the name
    }
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

    {
        gets all openings of a pipe and makes a string from it

        @param  IN:     the target cell
                OUT:    a string with all openings of the pipe
    }
    function cellOpeningsToString(cell:TCell):string;
    var
        stringBuilder:TStringBuilder;
        openingsRunner:PPositionNode;
    begin
        stringBuilder := TStringBuilder.create();
        openingsRunner := cell.openings.firstNode;
        while(openingsRunner <> nil) do begin
            stringBuilder := stringBuilder.append(
                '(' +
                inttostr(openingsRunner^.position.X) +
                '|' +
                inttostr(openingsRunner^.position.Y) +
                ') '
            );
            openingsRunner := openingsRunner^.next;
        end;
        cellOpeningsToString := stringBuilder.toString();
    end;

    {
        fills a cell with content

        @param  IN/OUT: target cell
                IN:     content type
    }
    procedure fillCellWithContent(var cell:TCell; content:TCellContent);
    begin
        cell.cellContent := content;
        loadPictureFromBitmap(cell);
    end;

    {
        returns true when a cell is empty

        @param  IN:     the target cell
                RETURN: true when cell is empty
    }
    function isCellEmpty(cell:TCell):boolean;
    begin
        isCellEmpty := cell.cellContent = TCellContent.CONTENT_EMPTY;
    end;

    {
        gets a cell from position

        @param  IN:     cellField with all cells
                        position (has to be in field!)
                RETURN: the cell on the position in field
    }
    function getCellFromPosition(cellField:TCellField; position:TPosition):TCell;
    begin
        getCellFromPosition := cellField[
            position.x,
            position.y
        ];
    end;

    {
        tells if a cell is connected to a position

        @param  IN:     cell the target cell
                        position of expected connection
    }
    function isCellConnected(cell:TCell; position:TPosition):boolean;
    var
        openingsRunner:PPositionNode;
        isConnected:boolean;
    begin
        isConnected := false;
        openingsRunner := cell.openings.firstNode;
        while((openingsRunner <> nil) and not isConnected) do begin
            isConnected := positionEquals(
                position,
                addPositions(
                    openingsRunner^.position,
                    getPositionFromName(cell.image.name)
                )
            );
            openingsRunner := openingsRunner^.next;
        end;

        isCellConnected := isConnected;
    end;
end.