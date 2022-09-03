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

end.