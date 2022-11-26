{
    file:       UFileHandler.pas
    title:      Floodpipes Filehandler
    author:     John Lienau
    version:    1.0
    date:       19.11.2022
    copyright:  Copyright (c) 2022

    brief:      Provides funcitions to handle fpg files to
                save and load a Floodpipe game
}

unit UFileHandler;
interface

    uses SysUtils, vcl.dialogs, UPositionFunctions, UFunctions, vcl.controls,  vcl.extctrls, UGameGeneration, UTypedefine;

    
    // return codes of the Filehandler functions 
    type TFileError = (
        FILE_ERROR_NONE,
        FILE_ERROR_FILE_DOESNT_EXIST,
        FILE_ERROR_COULD_NOT_WRITE_TO_FILE,
        FILE_ERROR_COUNT_NOT_READ_FROM_FILE
    );

    {
        creates, or writes, on filename 

        @param  IN      filename: the path, either from exe or
                        absolut path to the file
                        gameStruct: the game to save
                
                RETURN  a TFileError type
    }
    function saveGameToFile(
        filename:string;
        gameStruct:TGameStruct
    ):TFileError;

    {
        loads an gameStruct from an existing file

        @param  IN      filename: the path, either from exe or
                        absolut path to the file
                        gameStruct: the game to save
                        panelGAmefield: the parent panel of the cells
                        onCellMouseDown:The function pointer to the mouse event
                        cellGrid is the positioning of the cells
                
                RETURN  a TFileError type
    }
    function loadGameFromFile(
        filename:string;
        var gameStruct:TGameStruct;
        panelGamefield:TPanel;
        onCellMouseDown:TMouseEvent;
        cellGrid:TGridPanel
    ):TFileError;

implementation

    function saveGameToFile(
        filename:string;
        gameStruct:TGameStruct
    ):TFileError;
    var fileError:TFileError;
        gameFile:TextFile;
        i, j:integer;
    begin
        fileError := FILE_ERROR_NONE;

        AssignFile(gameFile, filename);
        try
            Rewrite(gameFile);

            // gamefield rows, then columns
            writeln(gameFile, gameStruct.cellRowLength);
            writeln(gameFile, gameStruct.cellColumnLength);
            // wallPercentage
            writeln(gameFile, gameStruct.wallPercentage);

            // gamefield cells
            for i := 0 to gameStruct.cellRowLength - 1 do
            begin
                for j := 0 to gameStruct.cellColumnLength - 1 do
                begin
                    write(gameFile, integer(gameStruct.cellField[j, i].cellType));
                    write(gameFile, ' ');
                    write(gameFile, integer(gameStruct.cellField[j, i].cellItem));
                    write(gameFile, ' ');
                    write(gameFile, integer(gameStruct.cellField[j, i].cellContent));
                    write(gameFile, ' ');
                    write(gameFile, integer(gameStruct.cellField[j, i].cellRotation));
                    write(gameFile, ' ');
                end;
                writeln(gameFile);
            end;

            // waterSourcePositionQueueList
            writeln(gameFile, positionListToString(gameStruct.waterSourcePositionQueueList));


            CloseFile(gameFile);
        except
            on E: Exception do
            begin
                fileError := FILE_ERROR_COULD_NOT_WRITE_TO_FILE;
            end;
        end;

        saveGameToFile := fileError;
    end;

    {
        gets columns from string to cellField

        @param  IN      line: the string of cells
                        removes the read celltypes from string
                        cellField: the gamefield where to put all cells
                        row: of cells in cellField
    }
    procedure stringRowToCellField(
        var line:string;
        var cellField:TCellField;
        row:integer
    );
        procedure cutCellTypeFromString(var cell:TCell; var line:string);
        begin
            cell.cellType := TCellType(strtoint(copy(
                line,
                1,
                pos(' ', line) - 1
            )));
            delete(line, 1, pos(' ', line));

            cell.cellItem := TCellItem(strtoint(copy(
                line,
                1,
                pos(' ', line) - 1
            )));
            delete(line, 1, pos(' ', line));

            cell.cellContent := TCellContent(strtoint(copy(
                line,
                1,
                pos(' ', line) - 1
            )));
            delete(line, 1, pos(' ', line));

            cell.cellRotation := TCellRotation(strtoint(copy(
                line,
                1,
                pos(' ', line) - 1
            )));
            delete(line, 1, pos(' ', line));
        end;

    var i:integer;
    begin
        for i := 0 to length(cellField[row]) - 1 do
        begin
            cutCellTypeFromString(cellField[i, row], line);
        end;
    end;

    procedure stringRowToWaterSourceList(
        var positionList:TPositionList;
        var line:string
    );
    begin
        while (line <> '') do
        begin
            appendPosition(
                positionList,
                integer(strtoint(copy(line, 1, pos(' ', line) - 1))),
                integer(strtoint(copy(line, 1, pos(' ', line) - 1)))
            );
            delete(line, 1, pos(' ', line));
            delete(line, 1, pos(' ', line));
        end;
    end;

    function loadGameFromFile(
        filename:string;
        var gameStruct:TGameStruct;
        panelGamefield:TPanel;
        onCellMouseDown:TMouseEvent;
        cellGrid:TGridPanel
    ):TFileError;
    var gameFile:TextFile;
        fileError:TFileError;
        line:string;
        i:integer;
    begin
        fileError := FILE_ERROR_NONE;

        AssignFile(gamefile, filename);
        try
            reset(gameFile);
            
            // gameField rows and columns
            readln(gameFile, line);
            gameStruct.cellRowLength := strtoint(line);
            readln(gameFile, line);
            gameStruct.cellColumnLength := strtoint(line);

            // create gamefield
            createCellGrid(
                cellGrid,
                gameStruct.waterSourcePositionQueueList,
                panelGamefield,
                gameStruct.cellField,
                gameStruct.cellRowLength,
                gameStruct.cellColumnLength,
                onCellMouseDown,
                true
            );

            // wallPercentage
            readln(gameFile, line);
            gameStruct.wallPercentage := strtoint(line);

            for i := 0 to gameStruct.cellRowLength - 1 do
            begin
                readln(gameFile, line);
                stringRowToCellField(line, gameStruct.cellField, i);
            end;

            delPositionList(gameStruct.waterSourcePositionQueueList);
            // get waterSources
            readln(gameFile, line);
            stringRowToWaterSourceList(gameStruct.waterSourcePositionQueueList, line);


            CloseFile(gameFile);
        except
            on E: Exception do
            begin
                fileError := FILE_ERROR_COUNT_NOT_READ_FROM_FILE;
            end;
        end;

        loadGameFromFile := fileError;
    end;
end.