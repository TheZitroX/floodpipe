{
    file:       UFluid.pas
    author:     John Lienau
    title:      Main unit of project Floodpipe
    version:    v1.0
    date:       01.09.2022
    copyright:  Copyright (c) 2022

    brief:      This unit contains the functions to move the fluid in the pipes
                and to set a water source at a position
}

unit UFluid;

interface

    uses UTypedefine, UPositionFunctions, UCellfunctions;

    {
        moves each fluid one position when called
        processes each position in positionQueueList, fills it with new when finished

        @param  IN/OUT: the cellField (gets changed when fluid is moving in pipes)
                        the positionQueueList is worked empty and fill when new positions are found
    }
    procedure fluidMove(
        var cellField:TCellField;
        var positionQueueList:TPositionList
    );

    {
        sets a water sourche at the position and pushes it to a positionList

        @param  IN/OUT: the cell on cellField changes to Water
                        positionQueueList gets a new position node

                IN:     position to place the source

                RETURN: true when success on placement
                        false when position is not in cellField or
                        position is not a pipe or
                        pipe has water
    }
    function setWaterSource(
        var cellField:TCellField;
        var positionQueueList:TPositionList;
        position:TPosition
    ):boolean;


implementation

    {
        moves fluid in all connections of a cell

        @param  IN/OUT: cellField (gets changed when fluid is moving in pipes)
                        positionQueueList (gets changed when new positions are found)
                        newPositionQueueList (gets filled with new positions)
    }
    procedure moveFluidInConnections(
        var cellField:TCellField;
        var positionQueueList, newPositionQueueList:TPositionList
    );
    var openingsRunner:PPositionNode;
        position, cellPosition:TPosition;
        cell:TCell;
    begin
        cellPosition := positionQueueList.firstNode^.position;
        cell := getCellFromPosition(cellField, cellPosition);

        openingsRunner := cell.openings.firstNode;
        // check all openings of the cell
        while(openingsRunner <> nil) do
        begin
            position := addPositions(
                openingsRunner^.position,
                cellPosition
            );
            // check if position is in cellField and position is a pipe and pipe has no water
            if (positionInField(cellField, position) and
                isCellEmpty(cellField[position.x, position.y]) and
                isCellConnected(cellField[position.x, position.y], cellPosition)) then
                begin
                    fillCellWithContent(
                        cellField[
                            position.x,
                            position.y
                        ],
                        TCellContent.CONTENT_WATER
                    );
                    appendPosition(newPositionQueueList, position.x, position.y);
            end;
            // go to next opening
            openingsRunner := openingsrunner^.next;
        end;
    end;
    
    procedure fluidMove(var cellField:TCellField; var positionQueueList:TPositionList);
    var
        newPositionQueueList:TPositionList;
    begin
        newPositionQueueList.firstNode := nil;
        // check all positions in positionQueueList
        while (not isPositionListEmpty(positionQueueList)) do
        begin
            moveFluidInConnections(
                cellField,
                positionQueueList,
                newPositionQueueList
            );
            delFirstPositionNode(positionQueueList);
        end;

        positionQueueList := newPositionQueueList;
    end;

    function setWaterSource(
        var cellField:TCellField;
        var positionQueueList:TPositionList;
        position:TPosition
    ):boolean;
    begin
        // check if position is in cellField and position is a pipe and pipe has no water
        if (positionInField(cellField, position) and
            positionEqualsType(
                cellField,
                position,
                TCellType.TYPE_PIPE
            ) and
            isCellEmpty(cellField[position.x, position.y])
        ) then
        begin
            setWaterSource := true;

            // check if position is already in positionQueueList
            if (not hasPosition(positionQueueList, position)) then
            begin
                fillCellWithContent(cellField[position.x, position.y], TCellContent.CONTENT_WATER);
                appendPosition(positionQueueList, position.x, position.y);
            end;
        end
        else // position is not in cellField or position is not a pipe or pipe has water
            setWaterSource := false;
    end;
end.