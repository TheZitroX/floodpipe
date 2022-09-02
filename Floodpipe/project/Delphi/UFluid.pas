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

    procedure fluidMove(var cellField:TCellField; var positionQueueList:PPositionNode);


implementation

    procedure moveFluidACell(var cellField:TCellField; positionQueueList:PPositionNode);
    var
        openingsRunner:PPositionNode;
        position, cellPosition:TPosition;
        cell:TCell;
    begin
        cellPosition.x := positionQueueList^.position.x;
        cellPosition.y := positionQueueList^.position.y;
        cell := cellField[
            cellPosition.x,
            cellPosition.y];

        openingsRunner := cell.openings;
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
    
    procedure fluidMove(var cellField:TCellField; var positionQueueList:PPositionNode);
    begin
        moveFluidACell(cellField, positionQueueList);
        delFirstPositionNode(positionQueueList);
    end;

end.