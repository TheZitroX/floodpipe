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

    uses SysUtils, vcl.dialogs, UPositionFunctions, UFunctions, vcl.controls,  vcl.extctrls, UGameGeneration, UTypedefine, Vcl.Forms, System.UITypes;

    
    type
        // return codes of the Filehandler functions 
        TFileError = (
            FILE_ERROR_NONE,
            FILE_ERROR_FILE_DOESNT_EXIST,
            FILE_ERROR_COULD_NOT_WRITE_TO_FILE,
            FILE_ERROR_COUNT_NOT_READ_FROM_FILE
        );

    const 
        // basic file information
        GAME_FILE_TYPE_EXTENSION = '.fpg';

    {
        saves the game to a file

        @param  IN/OUT  bNotSaved: boolean to set to false when game is saved
                
                IN      gameStruct: the game to save
                        form: the form to create the save dialog
    }
    procedure saveGame(
        gameStruct:TGameStruct;
        form:TForm;
        var bNotSaved:boolean
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

        @param  IN/OUT  bNotSaved: boolean to set to false when game is loaded
                        gameStruct: the game to load from file
                
                IN      form: the form to create the save dialog
                        panelGAmefield: the parent panel of the cells
                        onCellMouseDown:The function pointer to the mouse event
                        cellGrid is the positioning of the cells
    }
    procedure loadGame(
        var gameStruct:TGameStruct;
        form:TForm;
        panelGamefield:TPanel;
        onCellMouseDown:TMouseEvent;
        cellGrid:TGridPanel;
        var bNotSaved:boolean
    );
    
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

    procedure saveGame(
        gameStruct:TGameStruct;
        form:TForm;
        var bNotSaved:boolean
    );
    var fileError:TFileError;
        saveDialog:TSaveDialog;
        sFileName:string;
    begin
        fileError := FILE_ERROR_NONE;
        saveDialog := TSaveDialog.Create(form);

        // set the filter and the initial directory
        with saveDialog do
            begin
                // GAME_FILE_TYPE_EXTENSION is to show just the crosswise data and folders
                Filter := '|*' + GAME_FILE_TYPE_EXTENSION;
                // to start showing the gameSaves folder
                InitialDir := GetCurrentDir(); // shows the current directory of the program
            end;

        // when user clicked ok
        if saveDialog.Execute then
            begin
                sFileName := saveDialog.FileName;
                // when user did not specify the ending of sFileName the ending is added
                if not sFileName.endswith(GAME_FILE_TYPE_EXTENSION) then
                    sFileName := concat(sFileName, GAME_FILE_TYPE_EXTENSION);

                // when file exists, ask the user to overwrite it
                if fileexists(sFileName) then
                begin
                    // when user wants to overwrite the file
                    if (MessageDlg('Do you want to overwrite the file?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
                        fileError := saveGameToFile(sFileName, gameStruct);
                end
                else // file doesnt exist
                    fileError := saveGameToFile(sFileName, gameStruct);

                // show message to user depending on the error
                case fileError of
                    FILE_ERROR_FILE_DOESNT_EXIST: showmessage('file doesnt exist');
                    FILE_ERROR_COULD_NOT_WRITE_TO_FILE: showmessage('could not write to file');
                    FILE_ERROR_NONE: 
                    begin
                        ShowMessage('saved game');
                        bNotSaved := false;
                    end;

                    else showmessage('unknown error'); // should never happen
                end;
            end;
        saveDialog.free(); 
    end;

    procedure loadGame(
        var gameStruct:TGameStruct;
        form:TForm;
        panelGamefield:TPanel;
        onCellMouseDown:TMouseEvent;
        cellGrid:TGridPanel;
        var bNotSaved:boolean
    );
    var fileError:TFileError;
        openDialog:TOpenDialog;
        oldCellField:TCellField;
    begin
        // abfrage ob geladen werden soll
        if (MessageDlg('Do you want to load a game?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
        begin
            // ask for saving old game if not saved
            if (bNotSaved) and (MessageDlg(
                    'Do you want to save the current game?',
                    mtConfirmation,
                    [mbYes, mbNo],
                    0
                ) = mrYes) then
                saveGame(gameStruct, form, bNotSaved);
        
            openDialog := TOpenDialog.Create(form);

            with openDialog do
            begin
                // GAME_FILE_TYPE_EXTENSION is to show just the crosswise data and folders
                Filter := '|*' + GAME_FILE_TYPE_EXTENSION;
                // to start showing the gameSaves folder
                InitialDir := GetCurrentDir(); // shows the current directory of the program
            end;

            // save for deleting later when newCellField is generated
            oldCellField := gameStruct.cellField;

            if openDialog.Execute then
            begin
                fileError := loadGameFromFile(
                    openDialog.FileName,
                    gameStruct,
                    panelGamefield,
                    onCellMouseDown,
                    cellGrid
                );
                case fileError of
                    FILE_ERROR_COUNT_NOT_READ_FROM_FILE: ShowMessage('coulnd read from file');
                    FILE_ERROR_NONE: 
                    begin
                        ShowMessage('loaded game');
                        bNotSaved := false;
                    end;

                    else;
                end;
                // load variables when no error accoured
                if (fileError = FILE_ERROR_NONE) then
                begin
                    removeCellGrid(cellGrid, oldCellField);
                    generateGameFromGameStruct(gameStruct);
                end
                else
                begin
                    // restore old gamefield when file is currupted
                    gameStruct.cellField := oldCellField;
                end;
            end;

            // free the dialog when done
            openDialog.free();
        end;
    end;

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

    {
        gets all watersources and puts them to a positionList

        @param  IN/OUT  positionList: appends to it each position
                        line: gets the positions in 'x y ' format
                            and delets each position after reading
    }
    procedure stringRowToWaterSourceList(
        var positionList:TPositionList;
        var line:string
    );
    var x,y:integer;
    begin
        while (line <> '') do
        begin
            // read and delete X
            x := integer(strtoint(copy(line, 1, pos(' ', line) - 1)));
            delete(line, 1, pos(' ', line));

            // read and delete Y
            y := integer(strtoint(copy(line, 1, pos(' ', line) - 1)));
            delete(line, 1, pos(' ', line));

            appendPosition(
                positionList,
                x,
                y
            );
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

            // gamefield
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