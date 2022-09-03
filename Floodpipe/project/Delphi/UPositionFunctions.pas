{
    file:       UPositionFunctions.pas
    author:     John Lienau
    date:       02.09.2022
    version:    v1.0
    copyright:  Copyright (c) 2022

    brief:      provides operations for positions
}

unit UPositionFunctions;

interface

    uses UTypedefine;

    procedure rotatePosition(var position:TPosition);
    function isPositionListEmpty(positionList:TPositionList):boolean;
    procedure appendPositionNode(var positionList:TPositionList; positionNode:PPositionNode);
    procedure appendPosition(var positionList:TPositionList; positionX, positionY:integer);
    procedure delFirstPositionNode(var positionList:TPositionList);
    procedure rotatePositions(var cell:TCell);
    procedure rotatePositionsByCellRotation(var cell:TCell);
    function addPositions(position1, position2:TPosition):TPosition;
    function positionInField(cellField:TCellField; position:TPosition):boolean;

implementation
    {
        @brief: appends a positionNode to the end of the positionList

        @param: IN/OUT: positionList with the beginning of the list
                IN:     positionNode the appendend node
    }
    procedure appendPositionNode(var positionList:TPositionList; positionNode:PPositionNode);
    begin
        // set positionList when beginning doesnt exist
        if (positionList.firstNode = nil) then begin
            positionList.firstNode := positionNode;
            positionList.lastNode := positionNode;
        end else begin
            // set last element
            positionList.lastNode^.next := positionNode;
            positionList.lastNode := positionNode;
        end;
    end;

    {
        @brief: appends a new positionNode to the positionList
                creates the positionlist when empty

        @param: IN/OUT: positionList with the beginning of the list
                IN:     positionX (Y) with the positions
    }
    procedure appendPosition(var positionList:TPositionList; positionX, positionY:integer);
    var
        position:TPosition;
        positionNode:PPositionNode;
    begin
        position.x := positionX;
        position.y := positionY;
        new(positionNode);
        positionNode^.position := position;
        positionNode^.next := nil;
        appendPositionNode(positionList, positionNode);
    end;

    {
        @brief: deletes a positionNode from the beginning of the list

        @param: IN/OUT: positionList with the new beginning of the list
    }
    procedure delFirstPositionNode(var positionList:TPositionList);
    var
        tempPositionNode:PPositionNode;
    begin
        // ignore when already empty
        if (positionList.firstNode <> nil) then begin
            tempPositionNode := positionList.firstNode;
            positionList.firstNode := positionList.firstNode^.next;
            dispose(tempPositionNode);
        end;
    end;

    {
        checks if a list is empty

        @param  IN:     positionList
                RETURN: true when empty
    }
    function isPositionListEmpty(positionList:TPositionList):boolean;
    begin
        isPositionListEmpty := positionList.firstNode = nil;
    end;

    {
        Rotates position clockwise (90°)
        only (1, 0),(0,-1),(-1,0) and (0,-1) accepted!

        @param  IN/OUT: the position vector
    }
    procedure rotatePosition(var position:TPosition);
    begin
        case position.x of
            1: begin
                position.x := 0;
                position.y := 1;
            end;
            0:  begin
                if position.y = 1 then begin
                    position.x := -1;
                    position.y := 0;
                end else begin
                    position.x := 1;
                    position.y := 0;
                end;
            end;
            -1: begin
                position.x := 0;
                position.y := -1;
            end;
            else assert(true, 'ERROR cant rotate such position!');
        end;
    end;


    {
        rotates all cell openings by 90°

        @param  IN/OUT: target cell
    }
    procedure rotatePositions(var cell:TCell);
    var
        openingsRunner:PPositionNode;
    begin
        openingsRunner := cell.openings.firstNode;
        while(openingsRunner <> nil) do begin
            rotatePosition(openingsRunner^.position);
            openingsRunner := openingsRunner^.next;
        end;
    end;  

    {
        rotates all openings by cell rotation

        @param  IN/OUT: target cell
    }
    procedure rotatePositionsByCellRotation(var cell:TCell);
    var
        i:integer;
    begin
        for i := 1 to integer(cell.cellRotation) do
            rotatePositions(cell);
    end;

    {
        adds two positions with eachother
        
        @param  IN:     position1(2) added with eachother
                RETURN: added positions
    }
    function addPositions(position1, position2:TPosition):TPosition;
    begin
        addPositions.x := position1.x + position2.x;
        addPositions.y := position1.y + position2.y;
    end;

    {
        position in field checker
        
        @param  IN:     the cellfield has to be atleast 1x1
                        and position from type TPosition
                RETURN: true when in field
    }
    function positionInField(cellField:TCellField; position:TPosition):boolean;
    begin
        positionInField := 
            (position.x >= 0) and
            (position.y >= 0) and
            (position.x < length(cellField)) and
            (position.y < length(cellField[0]));
    end;
end.