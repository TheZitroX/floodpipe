{
  file:			UTypedefine.pas
  title:		Types for Floodpipe
  author:		John Lienau
  version:		1.0
  date:		    30.07.2022
  copyright:	Copyright (c) 2022

  brief:		Types used in UMain. Better Dont Change!
}

unit UTypedefine;
interface
    uses
        sysutils, vcl.extctrls, vcl.stdctrls,

        UProperties;

    type
        // cells
        TCell = TImage;
        TCellField = array of array of TCell;

        // cell item
        TCellItem = (
            EMPTY,
            PIPE
        );
        // rotation of cell
        TCellRotation = (
            NONE,
            FIRST,
            SECOND,
            THIRD
        );

        // position einer Celle
        TPosition = record
            x:integer;
            y:integer;
        end;
        // liste von positionen
        TPositionList = array of TPosition;

implementation
end.