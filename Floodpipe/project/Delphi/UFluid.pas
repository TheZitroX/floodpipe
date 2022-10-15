{
    file:       UFluid.pas
    author:     John Lienau
    title:      Main unit of project Floodpipe
    version:    v1.0
    date:       01.09.2022
    copyright:  Copyright (c) 2022

    brief:      Fluid symulations
}

unit UFluid;

interface

    uses UTypedefine, UPositionFunctions, UCellfunctions;

    procedure fluidMove(var cellField:TCellField; var positionQueueList:TPositionList);
    function setWaterSource(
        var cellField:TCellField;
        var positionQueueList:TPositionList;
        position:TPosition
    ):boolean;


implementation

    procedure moveFluidInConnections(
        var cellField:TCellField;
        var positionQueueList, newPositionQueueList:TPositionList);
    var
        openingsRunner:PPositionNode;
        position, cellPosition:TPosition;
        cell:TCell;
    begin
        cellPosition := positionQueueList.firstNode^.position;
        cell := getCellFromPosition(cellField, cellPosition);

        openingsRunner := cell.openings.firstNode;
        while(openingsRunner <> nil) do begin
            position := addPositions(
                openingsRunner^.position,
                cellPosition
            );
            if (positionInField(cellField, position) and
                isCellEmpty(cellField[position.x, position.y]) and
                isCellConnected(cellField[position.x, position.y], cellPosition)) then begin
                    fillCellWithContent(
                        cellField[
                            position.x,
                            position.y
                        ],
                        TCellContent.CONTENT_WATER
                    );
                    appendPosition(newPositionQueueList, position.x, position.y);
            end;
            openingsRunner := openingsrunner^.next;
        end;
    end;
    
    {
        processes each position in positionQueueList, fills it with new when finished

        @param  IN/OUT: the cellField (gets changed when fluid is moving in pipes)
                        the positionQueueList is worked empty and fill when new positions are found
    }
    procedure fluidMove(var cellField:TCellField; var positionQueueList:TPositionList);
    var
        newPositionQueueList:TPositionList;
    begin
        newPositionQueueList.firstNode := nil;
        while (not isPositionListEmpty(positionQueueList)) do begin
            moveFluidInConnections(
                cellField,
                positionQueueList,
                newPositionQueueList
            );
            delFirstPositionNode(positionQueueList);
        end;

        positionQueueList := newPositionQueueList;
    end;

    {
        sets a water sourche at the position and pushes it to a positionList

        @param  IN/OUT: the cell on cellField changes to Water
                        positionQueueList gets a new position node
                IN:     position to place the source
                RETURN: true when success on placement
                        false when position is not in cellField
    }
    function setWaterSource(
        var cellField:TCellField;
        var positionQueueList:TPositionList;
        position:TPosition
    ):boolean;
    begin
        if (positionInField(cellField, position)) then begin
            // todo when cell is also a pipe
            setWaterSource := true;
            fillCellWithContent(cellField[position.x, position.y], TCellContent.CONTENT_WATER);
            appendPosition(positionQueueList, position.x, position.y);
        end else setWaterSource := false;
    end;
end.