{
  // todo headder
}

unit UGameGeneration;

interface

    uses UTypedefine, UPositionFunctions, UCellFunctions, UPipeTypeFunctions, UFluid, Vcl.Dialogs;

    {
        Generates a game with given size and settings

        @param  IN/OUT  cellField with all cells
                        waterSourcePositionQueueList with all watersources
                
                IN      cellRow- and Columnlength of the field
                        wallPercentage between 0 and 100
    }
    procedure generateGame(
        cellField: TCellField;
        cellRowLength, cellColumnLength, wallPercentage: integer;
        var waterSourcePositionQueueList:TPositionList
    );

    {
        Generates a game with the given settings in gameStruct

        @param  IN/OUT  gameStruct: all settings
                        overrides the cellfield in gameStruct
    }
    procedure generateGameFromGameStruct(gameStruct:TGameStruct);

implementation

    procedure setRandomPossibleType(
        var cell: TCell;
        var waterSourcePositionQueueList:TPositionList;
        possibleDirectionList, needToHaveDirectionList: TPositionList
    );
    var
        neededPositionListRunner: PPositionNode;
        pipeTypeList: TPipeTypeList;
        cellItem: TCellItem;
        cellRotation: TCellRotation;
        tempCell: TCell;
        cellOkay: boolean;
        positionListRunner: PPositionNode;
    begin
        tempCell.openings.firstNode := nil;
        pipeTypeList.firstNode := nil;
        tempCell.cellType := TYPE_PIPE;

        if (positionListLength(possibleDirectionList) = 0) then
            setCellToItem(
                cell,
                waterSourcePositionQueueList,
                TCellType.TYPE_WALL,
                TCellItem.PIPE,
                TCellContent.CONTENT_EMPTY,
                TCellRotation.NONE,
                true
            )
        else if (positionListLength(possibleDirectionList) = 1) then
        begin
            tempCell.cellItem := TCellItem.PIPE_LID;
            tempCell.cellRotation := TCellRotation.NONE;
            setCellToItem(
                cell,
                waterSourcePositionQueueList,
                TCellType.TYPE_PIPE,
                tempCell.cellItem,
                TCellContent.CONTENT_EMPTY,
                tempCell.cellRotation,
                true
            );
            while (not hasPosition(cell.openings, possibleDirectionList.firstNode.position)) do
            begin
                rotateCellClockwise(cell);
            end;
        end else
        begin
            // all variations with needed openings
            for cellItem := TCellItem.PIPE to high(TCellItem) do
            begin
                tempCell.cellItem := cellItem;
                for cellRotation := low(TCellRotation) to high(TCellRotation) do
                begin
                    tempCell.cellRotation := cellRotation;
                    setOpeningsFromRotation(tempCell);

                    // checking tempCell to have all needed openings
                    cellOkay := true;
                    neededPositionListRunner := needToHaveDirectionList.firstNode;
                    while ((neededPositionListRunner <> nil) and cellOkay) do
                    begin
                        cellOkay := hasPosition(tempCell.openings,
                            neededPositionListRunner^.position);
                        neededPositionListRunner := neededPositionListRunner^.next;
                    end;
                    // tempCell with possible extra openings
                    positionListRunner := tempCell.openings.firstNode;
                    while((positionListRunner <> nil) and cellOkay) do
                    begin
                        cellOkay := hasPosition(possibleDirectionList,
                            positionListRunner^.position);
                        positionListRunner := positionListRunner^.next;
                    end;

                    // add to possible (pipetypeList) when cellOkay
                    if (cellOkay) then
                    begin
                        appendPipeType(pipeTypeList, tempCell.cellItem, tempCell.cellRotation);
                    end;
                end;
            end;
            getRandomType(pipeTypeList, tempCell.cellItem, tempCell.cellRotation);
            setCellToItem(
                cell,
                waterSourcePositionQueueList,
                TCellType.TYPE_PIPE,
                tempCell.cellItem,
                TCellContent.CONTENT_EMPTY,
                tempCell.cellRotation,
                true
            );
        end;

        delPipeTypeList(pipeTypeList);
    end;

    procedure getPositionsFromNeighboars(i, j:integer;
        var cellField:TCellField);
    var
        k:integer;
        var waterSourcePositionQueueList:TPositionList;
        possibleDirectionList, needToHaveDirectionList: TPositionList;
        position: TPosition;
    begin
        possibleDirectionList.firstNode := nil;
        needToHaveDirectionList.firstNode := nil;
        // every side
        for k := 0 to 3 do
        begin
            case k of
                // up
                0:
                    position := getPosition(i, j - 1);
                // right
                1:
                    position := getPosition(i + 1, j);
                // down
                2:
                    position := getPosition(i, j + 1);
                // left
                3:
                    position := getPosition(i - 1, j);
            end;
            // add position to possible position list
            if (positionInField(cellField, position) and
            not positionEqualsType(cellField, position,
            TCellType.TYPE_WALL)) then
            begin
                if isCellConnected(cellField[position.x, position.y],
                getPosition(i, j)) then
                begin
                    appendPosition(possibleDirectionList, position.x - i,
                        position.y - j);
                    appendPosition(needToHaveDirectionList, position.x - i,
                    position.y - j);
                end else if positionEqualsType(cellField, position, TCellType.TYPE_NONE) then
                    appendPosition(possibleDirectionList, position.x - i,
                        position.y - j);
            end;
        end;

        // if (possibleDirectionList.firstNode = nil) then showmessage('possible: empty');
        // if (needToHaveDirectionList.firstNode = nil) then showmessage('needed: empty');
        setRandomPossibleType(
            cellField[i, j],
            waterSourcePositionQueueList,
            possibleDirectionList,
            needToHaveDirectionList
        );

        // clearing memory
        delPositionList(possibleDirectionList);
        delPositionList(needToHaveDirectionList);
    end;

    procedure generateGame(
        cellField: TCellField;
        cellRowLength, cellColumnLength, wallPercentage: integer;
        var waterSourcePositionQueueList:TPositionList
    );
    var i, j, wallCount, maxWallCount:integer;
        waterSourcePosition:TPosition;
    begin
        waterSourcePosition := getPosition(
            random(cellColumnLength - 1),
            random(cellRowLength - 1)
        );
        // make random walls
        wallCount := 0;
        maxWallCount := round(((cellColumnLength * cellRowLength) / 100) * wallPercentage);
        for i := 0 to cellColumnLength - 1 do
            for j := 0 to cellRowLength - 1 do
            begin
                if (wallCount < maxWallCount) and
                    (random(cellColumnLength * cellRowLength) < 
                        (maxWallCount)) and
                    (not positionEquals(waterSourcePosition, getPosition(i, j))) then
                begin
                    setCellToItem(
                        cellField[i, j],
                        waterSourcePositionQueueList,
                        TCellType.TYPE_WALL,
                        TCellItem.PIPE,
                        TCellContent.CONTENT_EMPTY,
                        TCellRotation.NONE,
                        true
                    );
                    inc(wallCount);
                end;
            end;

        // make pipes
        for i := 0 to cellColumnLength - 1 do
            for j := 0 to cellRowLength - 1 do
            begin
                // make pipes when empty field
                if (positionEqualsType(cellField, getPosition(i, j), TCellType.TYPE_NONE)) then
                begin
                    getPositionsFromNeighboars(i, j, cellField);
                end;
            end;

        // deletes all and a new watersource
        delPositionList(waterSourcePositionQueueList);
        if not setWaterSource(
            cellField,
            waterSourcePositionQueueList,
            waterSourcePosition
        ) then assert(true, 'setWaterSource problem');

        // todo srumble rotations
    end;


    procedure generateGameFromGameStruct(gameStruct:TGameStruct);
    var i, j:integer;
    begin
        for i := 0 to gameStruct.cellRowLength - 1 do
            for j := 0 to gameStruct.cellColumnLength - 1 do
            begin
                setCellToItem(
                    gameStruct.cellField[j, i],
                    gameStruct.waterSourcePositionQueueList,
                    gameStruct.cellField[j, i].cellType,
                    gameStruct.cellField[j, i].cellItem,
                    gameStruct.cellField[j, i].cellContent,
                    gameStruct.cellField[j, i].cellrotation,
                    true
                );
                setOpeningsFromRotation(gameStruct.cellField[j, i]);
            end;
    end;
end.
