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
        // cell item
        TCellItem = (
            EMPTY,
            PIPE_LID_EMPTY,
            PIPE_EMPTY,
            PIPE_TSPLITS_EMPTY,
            PIPE_CURVES_EMPTY
        );
        // rotation of a cell
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
        TAttachedList = array of TPosition;
        // cell
        TCell = record
            image:TImage;
            cellItem:TCellItem;
            cellRotation:TCellRotation;
            position:TPosition;
            attachedList:TAttachedList;
        end;
        TCellField = array of array of TCell;

        // liste von positionen
        TPositionList = array of TPosition;

implementation
end.