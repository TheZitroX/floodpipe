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

    uses UTypedefine;

    procedure fluidMove(var positionQueueList:PPositionNode);
    function isPositionQueueListEmpty(positionQueueList:PPositionNode):boolean;
    procedure appendPositionNode(var positionList:PPositionNode; positionNode:PPositionNode);
    procedure appendPosition(var positionList:PPositionNode; positionX, positionY:integer);
    procedure delFirstPositionNode(var positionList:PPositionNode);

implementation
    {
        @brief: appends a positionNode to the end of the positionList
                Creates the positionList when empty

        @param: IN/OUT: positionList with the beginning of the list
                IN:     positionNode the appendend node
    }
    procedure appendPositionNode(var positionList:PPositionNode; positionNode:PPositionNode);
    begin
        if (positionList = nil) then begin
            positionList := positionNode;
        end else begin
            // get last element
            while (positionList^.next <> nil) do 
                positionList := positionList^.next;
            positionList^.next := positionNode;
        end;
    end;

    {
        @brief: appends a new positionNode to the positionList
                creates the positionlist when empty

        @param: IN/OUT: positionList with the beginning of the list
                IN:     positionX (Y) with the positions
    }
    procedure appendPosition(var positionList:PPositionNode; positionX, positionY:integer);
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
    procedure delFirstPositionNode(var positionList:PPositionNode);
    var
        tempPositionNode:PPositionNode;
    begin
        // ignore when already empty
        if (positionList <> nil) then begin
            tempPositionNode := positionList;
            positionList := positionList^.next;
            dispose(tempPositionNode);
        end;
    end;

    procedure fluidMove(var positionQueueList:PPositionNode);
    begin
    end;

    function isPositionQueueListEmpty(positionQueueList:PPositionNode):boolean;
    begin
        isPositionQueueListEmpty := positionQueueList = nil;
    end;
end.