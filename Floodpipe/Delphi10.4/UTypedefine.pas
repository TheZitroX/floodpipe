{
    file:			UTypedefine.pas
    title:		    Types for Floodpipe
    author:		    John Lienau
    version:		1.0
    date:		    30.07.2022
    copyright:	    Copyright (c) 2022

    brief:          This file contains all types and structs used in the program.
                    It is used to make the code more readable and to avoid errors.
}

// TODO: add more types (e.g. for fluids, ...) and add more comments to fill the gaps in the code and look more professional lol.
unit UTypedefine;

interface
    uses
        sysutils, vcl.extctrls, vcl.stdctrls,

        UProperties;

    type
        // cell types (pipe, wall)
        TCellType = (
            TYPE_NONE,
            TYPE_WALL,
            TYPE_PIPE
        );
        // pipe types (lid, pipe, t-split, curves)
        TCellItem = (
            PIPE_LID,
            PIPE,
            PIPE_TSPLIT,
            PIPE_CURVES
        );
        // can be expanded with other fluids (oil, lava, ...)
        TCellContent = (
            CONTENT_EMPTY,
            CONTENT_WATER
        );
        // rotation of a cell (0, 90, 180, 270) degrees
        TCellRotation = (
            NONE,
            FIRST,
            SECOND,
            THIRD
        );

        // button types for (pipe, wall, water source)
        TItemButton = (
            NONE_BUTTON,
            PIPE_LID_BUTTON,
            PIPE_BUTTON,
            PIPE_TSPLIT_BUTTON,
            PIPE_CURVE_BUTTON,
            WALL_BUTTON,
            WATER_SOURCE_BUTTON
        );
        // button types for (game mode, animate, generate new field, settings, load, save, exit)
        TSideButton = (
            GAMEMODE_BUTTON,
            ANIMATE_BUTTON,
            GENERATE_NEW_FIELD_BUTTON,
            SETTINGS_BUTTON,
            LOAD_BUTTON,
            SAVE_BUTTON,
            EXIT_BUTTON
        );

        // position struct (x, y)
        TPosition = record
            x:integer;
            y:integer;
        end;

        // Position list structure
        PPositionNode = ^TPositionNode;
        TPositionNode = record
            position:TPosition;
            next:PPositionNode;
        end;
        // List structure for positions
        TPositionList = record
            firstNode:PPositionNode;
            lastNode:PPositionNode;
        end;

        
        // pipetype node (contains all data of a pipe type)
        PPipeTypeNode = ^TPipeTypeNode;
        TPipeTypeNode = record
            cellItem:TCellItem;
            cellRotation:TCellRotation;
            next:PPipeTypeNode;
        end;
        // pipetype list (contains all pipe types)
        TPipeTypeList = record
            firstNode:PPipeTypeNode;
            lastNode:PPipeTypeNode;
        end;

        // cell struct (contains all data of a cell)
        TCell = record
            image:TImage; // NEED TO BE DISPOSED (image is created in the program)
            cellType:TCellType;
            cellItem:TCellItem;
            cellContent:TCellContent;
            cellRotation:TCellRotation;
            openings:TPositionList; // NEED TO BE DISPOSED (list is created in the program)
        end;
        TCellField = array of array of TCell;

        // game struct (contains all game data)
        TGameStruct = record
            cellField: TCellField;
            cellRowLength, cellColumnLength, wallPercentage: integer;
            waterSourcePositionQueueList:TPositionList
        end;

implementation
end.