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

    uses
        UTypedefine, SysUtils, vcl.dialogs, UPositionFunctions;

    type

        // return codes of the Filehandler functions 
        TFileError = (
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
                
                RETURN  a TFileError type
    }
    function loadGameFromFile(
        filename:string;
        var gameStruct:TGameStruct
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
            cell.cellType := TCellType(strtoint(copy(line, 1, pos(' ', line) - 1)));
            delete(line, 1, pos(' ', line));

            cell.cellItem := TCellItem(strtoint(copy(line, 1, pos(' ', line) - 1)));
            delete(line, 1, pos(' ', line));

            cell.cellContent := TCellContent(strtoint(copy(line, 1, pos(' ', line) - 1)));
            delete(line, 1, pos(' ', line));

            cell.cellRotation := TCellRotation(strtoint(copy(line, 1, pos(' ', line) - 1)));
            delete(line, 1, pos(' ', line));
        end;

    var i:integer;
    begin
        for i := 0 to length(cellField[row]) - 1 do
        begin
            cutCellTypeFromString(cellField[i, row], line);
        end;
    end;

    function loadGameFromFile(
        filename:string;
        var gameStruct:TGameStruct
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
            
            // todo reading in
            // gameField rows and columns
            readln(gameFile, line);
            gameStruct.cellRowLength := strtoint(line);
            readln(gameFile, line);
            gameStruct.cellColumnLength := strtoint(line);

            // wallPercentage
            readln(gameFile, line);
            gameStruct.wallPercentage := strtoint(line);

            for i := 0 to gameStruct.cellRowLength - 1 do
            begin
                readln(gameFile, line);
                stringRowToCellField(line, gameStruct.cellField, i);
            end;

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