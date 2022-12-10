{
    file:       UPositionFunctions.pas
    author:     John Lienau
    date:       02.09.2022
    version:    v1.0
    copyright:  Copyright (c) 2022

    brief:      contains functions for positions and positionLists (linked lists) for the game
}

unit UPositionFunctions;

interface

    uses UTypedefine, sysutils;

    {
        creates a position from input positions (x, y)

        @param  IN:     posX(Y) the positions
                RETURN: a position type from input positions (x, y)
    }
    function getPosition(posX, posY:integer):TPosition;

    {
        Rotates position clockwise (90°)
        only (1, 0),(0,-1),(-1,0) and (0,-1) accepted!
        Other positions will result in an error

        @param  IN/OUT: the position vector
    }
    procedure rotatePosition(var position:TPosition);

    {
        checks if a list is empty

        @param  IN:     positionList the list to check 
                RETURN: true when empty else false
    }
    function isPositionListEmpty(positionList:TPositionList):boolean;

    {
        @brief: appends a positionNode to the end of the positionList

        @param: IN/OUT: positionList with the beginning of the list
                IN:     positionNode the appendend node
    }
    procedure appendPositionNode(var positionList:TPositionList; positionNode:PPositionNode);

    {
        @brief: appends a new positionNode to the positionList
                creates the positionlist when empty

        @param: IN/OUT: positionList with the beginning of the list
                IN:     positionX (Y) with the positions
    }
    procedure appendPosition(
        var positionList:TPositionList;
        positionX, positionY:integer
    ); overload;

    {
        appends a position to positionList

        @param  IN/OUT  the positionList
                IN      the position
    }
    procedure appendPosition(
        var positionList:TPositionList;
        position:TPosition
    ); overload;

    {
        @brief: deletes a positionNode from the beginning of the list

        @param: IN/OUT: positionList with the new beginning of the list
    }
    procedure delFirstPositionNode(var positionList:TPositionList);

    {
        deletes every position in the list

        @param  IN/OUT: the positionList to be cleared
    }
    procedure delPositionList(var positionList:TPositionList);

    {
        rotates all cell openings by 90°

        @param  IN/OUT: target cell
    }
    procedure rotatePositions(var cell:TCell);

    {
        rotates all openings by cell rotation

        @param  IN/OUT: target cell
    }
    procedure rotatePositionsByCellRotation(var cell:TCell);
    
    {
        adds two positions with eachother
        
        @param  IN:     position1(2) added with eachother
                RETURN: added positions
    }
    function addPositions(position1, position2:TPosition):TPosition;
    
    {
        position in field checker
        
        @param  IN:     cellField the cellfield has to be atleast 1x1
                        and position from type TPosition
                RETURN: true when in field else false when not in field
    }
    function positionInField(cellField:TCellField; position:TPosition):boolean;
    
    {
        tells if two positions points to the same

        @param  IN:     position1(2) the checked positions
                RETURN: true when they point to the same location
    }
    function positionEquals(position1, position2:TPosition):boolean;
    
    {
        tells if a position is in the positionList

        @param: IN:     positionList with all positions
                        position the position check against the positionList
                RETURN: true when found and false when not found
    }
    function hasPosition(positionList:TPositionList; position:TPosition):boolean;

    {
        Makes a positionList to a string

        @param  IN      positionList: the positionList

                RETURN  positionList to a string
    }
    function positionListToString(positionList:TPositionList):string;

    {
        makes a position to a string

        @param  IN      position the postion

                RETURN  position to string
    }
    function positionToString(position:TPosition):string;

    {
        removes all position in positionList

        @param  IN/OUT  positionList with all positions
                IN      position where all occurrences are deleted
    }
    procedure removePositions(
        var positionList:TPositionList;
        position:TPosition
    );

    {
        gets the length of a positionList

        @param  IN:     the positionList to get the length from
                RETURN: length of the list (0 when empty)
    }
    function positionListLength(positionList:TPositionList):integer;

implementation
    {
        makes a TPosition from input positions

        @param  IN:     posX(Y) the positions
                RETURN: a position type from input
    }
    function getPosition(posX, posY:integer):TPosition;
    begin
        getPosition.x := posX;
        getPosition.y := posY;
    end;

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

    procedure appendPosition(
        var positionList:TPositionList;
        positionX, positionY:integer
    );
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

    procedure appendPosition(
        var positionList:TPositionList;
        position:TPosition
    );
    var positionNode:PPositionNode;
    begin
        new(positionNode);
        positionNode^.position := position;
        positionNode^.next := nil;
        appendPositionNode(positionList, positionNode);
    end;

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

    procedure delPositionList(var positionList:TPositionList);
    begin
        while (not isPositionListEmpty(positionList)) do
            delFirstPositionNode(positionList);
        positionList.lastNode := nil;
    end;

    function isPositionListEmpty(positionList:TPositionList):boolean;
    begin
        isPositionListEmpty := positionList.firstNode = nil;
    end;

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

    procedure rotatePositionsByCellRotation(var cell:TCell);
    var
        i:integer;
    begin
        for i := 1 to integer(cell.cellRotation) do
            rotatePositions(cell);
    end;

    function addPositions(position1, position2:TPosition):TPosition;
    begin
        addPositions.x := position1.x + position2.x;
        addPositions.y := position1.y + position2.y;
    end;

    function positionInField(cellField:TCellField; position:TPosition):boolean;
    begin
        positionInField := 
            (position.x >= 0) and
            (position.y >= 0) and
            (position.x < length(cellField)) and
            (position.y < length(cellField[0]));
    end;

    function positionEquals(position1, position2:TPosition):boolean;
    begin
        positionEquals := (
            (position1.x = position2.x) and
            (position1.y = position2.y)
        );
    end;

    function hasPosition(positionList:TPositionList; position:TPosition):boolean;
    var
        positionListRunner:PPositionNode;
        found:boolean;
    begin
        positionListRunner := positionList.firstNode;
        found := false;
        while((positionListRunner <> nil) and not found) do begin
            found := positionEquals(
                positionListRunner.position,
                position
            );
            positionListRunner := positionListRunner^.next;
        end;
        hasPosition := found;
    end;

    function positionListLength(positionList:TPositionList):integer;
    var
        listLength:integer;
        positionListRunner:PPositionNode;
    begin
        listLength := 0;
        positionListRunner := positionList.firstNode;
        while (positionListRunner <> nil) do
        begin
            inc(listLength);
            positionListRunner := positionListRunner^.next;
        end;
        positionListLength := listLength;
    end;

    procedure removePositions(
        var positionList:TPositionList;
        position:TPosition
    );
    var beforePosition, positionListRunner:PPositionNode;
    begin
        positionListRunner := positionList.firstNode;
        beforePosition := nil;

        while positionListRunner <> nil do
        begin
            if positionEquals(positionListRunner^.position, position) then
                if positionListRunner = positionList.firstNode then
                begin
                    delFirstPositionNode(positionList);
                    beforePosition := positionList.firstNode;
                    positionListRunner := positionList.firstNode;
                end
                else
                begin
                    beforePosition^.next := positionListRunner^.next;
                    dispose(positionListRunner);
                    positionListRunner := beforePosition^.next;
                end;
        end;
    end;

    function positionToString(position:TPosition):string;
    begin
        positionToString := inttostr(position.x) + ' ' + inttostr(position.y);
    end;

    function positionListToString(positionList:TPositionList):string;
    var positionListRunner:PPositionNode;
        stringBuilder:TStringBuilder;
    begin
        stringBuilder := TStringBuilder.Create();

        positionListRunner := positionList.firstNode;
        while(positionListRunner <> nil) do
        begin
            stringBuilder := stringBuilder.append(positionToString(positionListRunner^.position));
            stringBuilder := stringBuilder.append(' ');
            positionListRunner := positionListRunner^.next;
        end;

        positionListToString := stringBuilder.toString();
    end;

end.