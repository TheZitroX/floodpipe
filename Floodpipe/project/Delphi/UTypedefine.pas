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
        // cell types (pipe, wall);
        TCellType = (
            TYPE_WALL,
            TYPE_PIPE
        );
        TCellItem = (
            PIPE,
            PIPE_LID,
            PIPE_TSPLIT,
            PIPE_CURVES
        );
        // can be expanded with other fluids
        TCellContent = (
            CONTENT_EMPTY,
            CONTENT_WATER
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
            cellType:TCellType;
            cellItem:TCellItem;
            cellContent:TCellContent;
            cellRotation:TCellRotation;
            position:TPosition;
            attachedList:TAttachedList;
        end;
        TCellField = array of array of TCell;

        // liste von positionen
        TPositionList = array of TPosition;

implementation
end.