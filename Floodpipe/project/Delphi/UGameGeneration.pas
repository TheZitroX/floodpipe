{
  // todo headder
}

unit UGameGeneration;

interface

uses UTypedefine, UPositionFunctions, UCellFunctions, UPipeTypeFunctions, Vcl.Dialogs;

procedure generateGame(cellField: TCellField;
  cellRowLength, cellColumnLength: integer);

implementation

procedure setRandomPossibleType(var cell: TCell;
  possibleDirectionList, needToHaveDirectionList: TPositionList);
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
    if (positionListLength(possibleDirectionList) = 1) then
    begin
        tempCell.cellItem := TCellItem.PIPE_LID;
        tempCell.cellRotation := TCellRotation.NONE;
        setCellToItem(cell, TCellType.TYPE_PIPE, tempCell.cellItem,
            TCellContent.CONTENT_EMPTY, tempCell.cellRotation);
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
        setCellToItem(cell, TCellType.TYPE_PIPE, tempCell.cellItem,
            TCellContent.CONTENT_EMPTY, tempCell.cellRotation);
    end;

    delPipeTypeList(pipeTypeList);
end;

procedure generateGame(cellField: TCellField;
  cellRowLength, cellColumnLength: integer);
var
    i, j, k: integer;
    possibleDirectionList, needToHaveDirectionList: TPositionList;
    position: TPosition;
    auswahl: TCell;
begin
    possibleDirectionList.firstNode := nil;
    needToHaveDirectionList.firstNode := nil;

    for i := 0 to cellColumnLength - 1 do
        for j := 0 to cellRowLength - 1 do
        begin
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
            setRandomPossibleType(cellField[i, j], possibleDirectionList,
              needToHaveDirectionList);

            // clearing memory
            delPositionList(possibleDirectionList);
            delPositionList(needToHaveDirectionList);
        end;
end;

end.
