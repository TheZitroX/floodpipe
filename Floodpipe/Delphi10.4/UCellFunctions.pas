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

    {
        Creates a cell with name and parant

        @param  IN/OUT  cell: as target

                IN      newParent: the parant of target
                        newName: the name of target
    }
    procedure cellSetup(
        var cell:TCell;
        newParent:TWinControl;
        newName:string
    );

    {
        creates a field (rows * columns) of TCellField

        @param  IN/OUT  cellField: the field of TPanel
                        waterSourcePositionQueueList: with all water positions

                IN      newParent: the parent of cellField
                        rowCount: the row-count
                        columnCount: the column-count
                        onCellClick: as mouseEvent
                        overrideTypes: when true all types of cellField will be overriden
    }
    procedure createCells(
        var cellField:TCellField;
        var waterSourcePositionQueueList:TPositionList; 
        newParent:TWinControl;
        rowCount, columnCount:integer;
        onCellClick:TMouseEvent;
        overrideTypes:boolean
    );

    {
        @brief  increments the rotational state of a cell
                and updates the bitmap of it
        
        @param  IN/OUT  cell: the rotated cell
    }
    procedure rotateCellClockwise(var cell:TCell);

    {
        @brief  gets the position of a cell name

        @param  IN      string: the cell name

        @return TPosition: with the x and y values of the name
    }
    function getPositionFromName(name:string):TPosition;

    {
        gets all openings of a pipe and makes a string from it

        @param  IN      the target cell

        @return a string with all openings of the pipe
    }
    function cellOpeningsToString(cell:TCell):string;

    {
        sets a cell to the passed types

        @param  IN/OUT  cell: the target cell
                        waterSourcePositionQueueList: with water positions

                IN      celltype,
                        cellitem,
                        cellContent,
                        cellRotation
                        overrideTypes: when true all types will be overridden to newTypes
    }
    procedure setCellToItem(
        var cell:TCell;
        var waterSourcePositionQueueList:TPositionList;
        newCellType:TCellType;
        newCellItem:TCellItem;
        newCellContent:TCellContent;
        newCellRotation:TCellRotation;
        overrideTypes:boolean
    );

    {
        sets all cells in cellField to the passed types
        sets or clears the waterSources

        @param  IN/OUT  cellField: with 2d cell array
                        waterSourcePositionQueueList: with water positions

                IN      celltype,
                        cellitem,
                        cellContent,
                        cellRotation
    }
    procedure setCellFieldToItem(
        var cellField:TCellField;
        var waterSourcePositionQueueList:TPositionList;
        newCellType:TCellType;
        newCellItem:TCellItem;
        newCellContent:TCellContent;
        newCellRotation:TCellRotation
    );

    {
        fills a cell with content

        @param  IN/OUT  cell: target cell

                IN      content: of type TCellContent
    }
    procedure fillCellWithContent(var cell:TCell; content:TCellContent);

    {
        gives information about the cell content (empty or full)

        @param  IN      cell: the target cell

        @return true when cell is empty
    }
    function isCellEmpty(cell:TCell):boolean;

    {
        gets a cell from position

        @param  IN      cellField: with all cells
                        position: (has to be in field!)

        @return the cell on the position in field
    }
    function getCellFromPosition(cellField:TCellField; position:TPosition):TCell;

    {
        tells if a cell is connected to a position

        @param  IN      cell: the target cell
                        position: of expected connection
        
        @return false if celltype is not TYPE_PIPE
    }
    function isCellConnected(cell:TCell; position:TPosition):boolean;

    {
        checks for equal types on cell and position

        @param  IN      cellField: with cells
                        position: of target cell in field
                        and the cellType
                    
        @return true when cellType equals type of position in cellField
    }
    function positionEqualsType(
        cellField:TCellField;
        position:TPosition;
        cellType:TCellType
    ):boolean;

    {
        sets the openings from type and rotation of a cell

        @param  IN/OUT  cell: the target cell
    }
    procedure setOpeningsFromRotation(var cell:TCell);

implementation

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
        var waterSourcePositionQueueList:TPositionList;
        newCellType:TCellType;
        newCellItem:TCellItem;
        newCellContent:TCellContent;
        newCellRotation:TCellRotation;
        overrideTypes:boolean
    );
    begin
        if (overrideTypes) then
        begin
            // remove water source from queue if cell is water and new cell is not water and in queue
            if (cell.cellContent = CONTENT_WATER) and
                (newCellContent <> CONTENT_WATER) and
                hasPosition(waterSourcePositionQueueList, getPositionFromName(cell.image.Name)) then
                removePositions(waterSourcePositionQueueList, getPositionFromName(cell.image.Name))
            // add water source to queue if cell is empty and new cell is water and not already in queue
            else if ((cell.cellContent = CONTENT_EMPTY) and
                (newCellContent = CONTENT_WATER)) and
                not hasPosition(waterSourcePositionQueueList, getPositionFromName(cell.image.Name)) then
                appendPosition(waterSourcePositionQueueList, getPositionFromName(cell.image.Name));

            with cell do
            begin
                cellType := newCellType;
                cellItem := newCellItem;
                cellContent := newCellContent;
                cellRotation := newCellRotation;
            end;
        end;

        loadPictureFromBitmap(cell);
        setOpeningsFromRotation(cell);
    end;

    procedure setCellFieldToItem(
        var cellField:TCellField;
        var waterSourcePositionQueueList:TPositionList;
        newCellType:TCellType;
        newCellItem:TCellItem;
        newCellContent:TCellContent;
        newCellRotation:TCellRotation
    );
    var i,j:integer;
    begin
        for i := 0 to length(cellField) - 1 do
            for j := 0 to length(cellField[0]) - 1 do
            begin
                setCellToItem(
                    cellField[i, j],
                    waterSourcePositionQueueList,
                    newCellType,
                    newCellItem,
                    newCellContent,
                    newCellRotation,
                    true
                );
            end;
    end;

    procedure setOpeningsFromRotation(var cell:TCell);
    begin
        with cell do
        begin
            // clear openings
            if (not isPositionListEmpty(openings)) then
                delPositionList(openings);

            case cellType of
                TYPE_NONE:;
                TYPE_WALL:;// do nothing
                TYPE_PIPE: 
                    begin
                        case cellItem of
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
                        // rotate openings by rotation of cell (clockwise)
                        rotatePositionsByCellRotation(cell);
                    end;
                else assert(true, 'ERROR cant set openings from this type');
            end;
        end;
    end;

    procedure createCells(
        var cellField:TCellField;
        var waterSourcePositionQueueList:TPositionList; 
        newParent:TWinControl;
        rowCount, columnCount:integer;
        onCellClick:TMouseEvent;
        overrideTypes:boolean
    );
    var
        i, j:integer;
    begin
        // create the array-field with the needed length
        setLength(cellField, columnCount, rowCount);
        // create cells
        for j := 0 to rowCount - 1 do
            for i := 0 to columnCount - 1 do
            begin
                cellSetup(
                    cellField[i, j],
                    newParent,
                    'cellx' + inttostr(i) + 'y' + inttostr(j)
                );
                cellField[i][j].image.Align := alClient;
                setCellToItem(
                    cellField[i, j],
                    waterSourcePositionQueueList,
                    // debug just random types for testing
                    TCellType.TYPE_NONE,
                    TCellItem(Random(Succ(Ord(High(TCellItem))))),
                    // TCellItem.PIPE,
                    // TCellContent(Random(Succ(Ord(High(TCellContent))))),
                    TCellContent.CONTENT_EMPTY,
                    TCellRotation(Random(Succ(Ord(High(TCellRotation))))),
                    // TCellRotation.NONE,
                    overrideTypes
                );
                cellField[i, j].openings.firstNode := nil;
                setOpeningsFromRotation(cellField[i, j]);
                cellField[i][j].image.OnMouseDown := onCellClick;
            end;
    end;

    procedure rotateCellClockwise(var cell:TCell);
    begin
        if (cell.cellRotation = high(TCellRotation)) then
            cell.cellRotation := low(TCellRotation)
        else inc(cell.cellRotation);
        loadPictureFromBitmap(cell);
        rotatePositions(cell);
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

    procedure fillCellWithContent(var cell:TCell; content:TCellContent);
    begin
        cell.cellContent := content;
        loadPictureFromBitmap(cell);
    end;

    function isCellEmpty(cell:TCell):boolean;
    begin
        isCellEmpty := cell.cellContent = TCellContent.CONTENT_EMPTY;
    end;

    function getCellFromPosition(cellField:TCellField; position:TPosition):TCell;
    begin
        getCellFromPosition := cellField[
            position.x,
            position.y
        ];
    end;

    function isCellConnected(cell:TCell; position:TPosition):boolean;
    var
        openingsRunner:PPositionNode;
        isConnected:boolean;
    begin
        isConnected := false;
        if (cell.celltype = TCellType.TYPE_PIPE) then begin
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
        end;
        isCellConnected := isConnected;
    end;

    function positionEqualsType(cellField:TCellField; position:TPosition; cellType:TCellType):boolean;
    begin
        positionEqualsType := cellField[position.x, position.y].cellType = cellType;
    end;
end.