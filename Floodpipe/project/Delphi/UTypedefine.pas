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
            TYPE_NONE,
            TYPE_WALL,
            TYPE_PIPE
        );
        TCellItem = (
            PIPE_LID,
            PIPE,
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

    
        TItemButton = (
            NONE_BUTTON,
            PIPE_LID_BUTTON,
            PIPE_BUTTON,
            PIPE_TSPLIT_BUTTON,
            PIPE_CURVE_BUTTON,
            WALL_BUTTON,
            WATER_SOURCE_BUTTON
        );
        TSideButton = (
            GAMEMODE_BUTTON,
            ANIMATE_BUTTON,
            GENERATE_NEW_FIELD_BUTTON,
            SETTINGS_BUTTON,
            LOAD_BUTTON,
            SAVE_BUTTON,
            EXIT_BUTTON
        );

        // position einer Celle
        TPosition = record
            x:integer;
            y:integer;
        end;

        // Position list
        PPositionNode = ^TPositionNode;
        TPositionNode = record
            position:TPosition;
            next:PPositionNode;
        end;
        // List structure
        TPositionList = record
            firstNode:PPositionNode;
            lastNode:PPositionNode;
        end;

        
        // pipetype node
        PPipeTypeNode = ^TPipeTypeNode;
        TPipeTypeNode = record
            cellItem:TCellItem;
            cellRotation:TCellRotation;
            next:PPipeTypeNode;
        end;
        // pipetype list
        TPipeTypeList = record
            firstNode:PPipeTypeNode;
            lastNode:PPipeTypeNode;
        end;

        // cell
        TCell = record
            image:TImage; // NEED TO BE DISPOSED
            cellType:TCellType;
            cellItem:TCellItem;
            cellContent:TCellContent;
            cellRotation:TCellRotation;
            openings:TPositionList; // NEED TO BE DISPOSED
        end;
        TCellField = array of array of TCell;

        TGameStruct = record
            cellField: TCellField;
            cellRowLength, cellColumnLength, wallPercentage: integer;
            waterSourcePositionQueueList:TPositionList
        end;

implementation
end.