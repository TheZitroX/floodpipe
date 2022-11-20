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
            FILE_ERROR_COULD_NOT_WRITE_TO_FILE
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

            // todo gamefield
            // writeln(gameFile, integer(gameStruct.cellField[0][0].cellType));

            // todo waterSourcePositionQueueList
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

end.