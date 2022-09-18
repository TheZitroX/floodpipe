{
    // todo headder
}

unit UGameGeneration;

interface

    uses UTypedefine, UPositionFunctions, UCellFunctions;

    procedure generateGame(
        cellField:TCellField;
        cellRowLength, cellColumnLength:integer
    );

implementation

    procedure generateGame(
        cellField:TCellField;
        cellRowLength, cellColumnLength:integer
    );
    var
        i, j, k:integer;
        possiblePositionList, needToHavePositionList:TPositionList;
        position:TPosition;
    begin
        possiblePositionList.firstNode := nil;
        needToHavePositionList.firstNode := nil;

        for i := 0 to cellColumnLength - 1 do
            for j := 0 to cellRowLength - 1 do begin
                // every side
                for k := 0 to 3 do begin
                    case k of
                        // up
                        0:  position := getPosition(i,      j - 1);
                        // right
                        1:  position := getPosition(i + 1,  j);
                        // down
                        2:  position := getPosition(i,      j + 1);
                        // left
                        3:  position := getPosition(i - 1,  j);
                    end;
                    // add position to possible position list
                    if (positionInField(cellField, position)) then begin
                        appendPosition(possiblePositionList, position.x, position.y);
                        if isCellConnected(
                            cellField[position.x, position.y],
                            getPosition(i, j)
                        ) then appendPosition(needToHavePositionList, position.x, position.y);
                    end;
                end;
                // todo check possible combination and save them in a list
                // todo choose a one of them randomly and place it on the cellField


                // clearing memory
                delPositionList(possiblePositionList);
                delPositionList(needToHavePositionList);
            end;
    end;

end.