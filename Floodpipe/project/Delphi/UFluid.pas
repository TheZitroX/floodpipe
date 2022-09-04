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

    procedure moveFluidInConnections(var cellField:TCellField; var positionQueueList:TPositionList);
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
            if positionInField(cellField, position) and isCellEmpty(cellField[position.x, position.y]) then begin
                fillCellWithContent(
                    cellField[
                        position.x,
                        position.y
                    ],
                    TCellContent.CONTENT_WATER
                );
                appendPosition(positionQueueList, position.x, position.y);
            end;
            openingsRunner := openingsrunner^.next;
        end;
    end;
    
    procedure fluidMove(var cellField:TCellField; var positionQueueList:TPositionList);
    begin
        moveFluidInConnections(cellField, positionQueueList);
        delFirstPositionNode(positionQueueList);
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
            setWaterSource := true;
            fillCellWithContent(cellField[position.x, position.y], TCellContent.CONTENT_WATER);
            appendPosition(positionQueueList, position.x, position.y);
        end else setWaterSource := false;
    end;

end.