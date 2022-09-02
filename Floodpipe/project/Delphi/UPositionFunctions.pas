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
    procedure rotatePositions(var cell:TCell);
    procedure rotatePositionsByCellRotation(var cell:TCell);
    function addPositions(position1, position2:TPosition):TPosition;

implementation
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
        i:integer;
        openingsRunner:PPositionNode;
    begin
        openingsRunner := cell.openings;
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
        addPositions.x := position1.x +  position2.x;
        addPositions.y := position1.y +  position2.y;
    end;
end.