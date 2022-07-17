{
  file:			UFileHandler.pas
  author:		John Lienau (yourmom@ctemplar.com)
  title:		Crosswise - functions
  version:		1.0
  date:			05.06.2022
  copyright:	Copyright (c) 2022

  brief:		FileHandler provides functions to handle cwd files to save and load them
}

unit UFileHandler;

    interface

        uses
            sysutils, Vcl.Dialogs,

            UProperties, UMainTypeDefine, UFileHandlerFunctions;
    
        // functions called outside this unit (public)
        function readGameSaveToVariables(
            filename:string;
            var gamefieldList:TGamefileGamefieldList;
            var playerList:TPlayerList;
            var playersTurn:TPlayersTurn;
            var playerCount:integer):boolean;

        function writeVariablesToGameSave(
            filename:string;
            gamefieldList:TGamefileGamefieldList;
            playerList:TPlayerList;
            playersTurn:TPlayersTurn;
            playerCount:integer):boolean;

        implementation
            {
                @brief  read a *.cwd file to the main variable in UMain
                        when a file is currupted or not in the excpected fileformat,
                        it tells where the fail accouered.

                @param  filename as string
                        gamefieldList as TGamefileGamefieldList IN and OUT
                        playersTurn as TPlayersTurn IN and OUT
                @return boolean true as worked and false as an error eccured
            }
            // optimize is it good to get variables like this (var)?
            function readGameSaveToVariables(
                filename:string;
                var gamefieldList:TGamefileGamefieldList;
                var playerList:TPlayerList;
                var playersTurn:TPlayersTurn;
                var playerCount:integer):boolean;

                const
                    ERROR_PREFIX = 'Error: ';
                var
                    i, j:integer;
                    gamefile:textfile;
                    gamefileLine:string;
                    // linecount is used to give information about an error on wich line of the gamefile
                    linecount:integer;
                    badGamefile:boolean;

                    // temp var's of the gamefile
                    gamefilePlayerCount:integer;
                    gamefilePlayerNames:TGamefilePlayerNameList;
                    gamefilePlayerAIStateList:TGamefilePlayerAIStateList;
                    gamefileGamefieldList:TGamefileGamefieldList;
                    gamefilePlayerInventoryList:TGamefilePlayerInventoryList;
                    gamefilePlayersTurn:TPlayersTurn;

                begin
                    assignfile(gamefile, filename);
                    reset(gamefile);

                    linecount := 0;
                    badGamefile := false;
                    // go throu all lines of the file
                    while (not eof(gamefile)) and (not badGamefile) do
                        begin
                            readln(gamefile, gamefileLine);
                            inc(linecount);

                            case linecount of
                                // reading playercount
                                1: begin
                                        gamefilePlayerCount := getNumberFromString(gamefileLine);
                                        badGamefile := not ((gamefilePlayerCount = 2) or (gamefilePlayerCount = 4));
                                    end;

                                // reading playernames
                                2:  badGamefile := readPlayerNamesFromGamefileLine(gamefileLine, gamefilePlayerNames);

                                // reading ai states for players
                                3:  badGamefile := readPlayerAIStateFromGamefileLine(gamefileLine, gamefilePlayerAIStateList);

                                // reading gamefield
                                GAMEFIELD_LINE_START_IN_FILE..GAMEFIELD_LINE_START_IN_FILE + (GAMEFIELD_COLUMNS - 1): begin
                                        j := 0;
                                        // go throu each column
                                        while (not badGamefile) and (j < GAMEFIELD_COLUMNS) do
                                            begin
                                                badGamefile := readGamefieldFromGamefileLine(
                                                    gamefileLine,
                                                    gamefileGamefieldList[linecount - GAMEFIELD_LINE_START_IN_FILE,
                                                    j]);
                                                // go to next column
                                                inc(j);
                                            end;
                                    end;

                                // reading inventory
                                PLAYER_INVENTORY_LINE_START_IN_FILE..PLAYER_INVENTORY_LINE_START_IN_FILE + (PLAYER_COUNT_MAX - 1): begin
                                        j := 0;
                                        // go throu each player
                                        while (not badGamefile) and (j < PLAYER_COUNT_MAX) do
                                            begin
                                                badGamefile := readItemFromGamefileLine(
                                                    gamefileLine,
                                                    gamefilePlayerInventoryList[linecount - PLAYER_INVENTORY_LINE_START_IN_FILE,
                                                    j]);
                                                // next player
                                                inc(j);
                                            end;
                                    end;

                                // reading players turn
                                14: badGamefile := getPlayersTurnFromGamefileLine(gamefileLine, gamefilePlayersTurn);

                                // todo reading marked inventory
                                15:;

                                // todo reading action-stone count
                                16:;

                                // if file is too long
                                else badGamefile := true;
                            end;
                        end;
                    // file-read completed
                    closefile(gamefile);

                    // write variables to main unit
                    if badGamefile then
                        // todo UFileHandlerErrorHandler -> function
                        case linecount of
                            // no line read
                            0: showmessage(ERROR_PREFIX + 'This file is emty!');

                            // reading playercount
                            1: showmessage(ERROR_PREFIX + 'Counldnt read playercount on Line ' + inttostr(linecount));

                            // reading playernames
                            2: showmessage(ERROR_PREFIX + 'Couldnt read playernames on line ' + inttostr(linecount));

                            // reading ai-state
                            3: showmessage(ERROR_PREFIX + 'Couldnt read players ai state on line ' + inttostr(linecount));

                            // reading gamefiels
                            GAMEFIELD_LINE_START_IN_FILE..GAMEFIELD_LINE_START_IN_FILE + (GAMEFIELD_COLUMNS - 1): 
                                showmessage(ERROR_PREFIX + 'Couldnt read gamefields on line ' + inttostr(linecount));

                            // reading inventory
                            PLAYER_INVENTORY_LINE_START_IN_FILE..PLAYER_INVENTORY_LINE_START_IN_FILE + (PLAYER_COUNT_MAX - 1):
                                showmessage(ERROR_PREFIX + 'Couldnt read inventory on line ' + inttostr(linecount));

                            // reading playersTurn
                            14: showmessage(ERROR_PREFIX + 'Couldnt read playersTurn on Line ' + inttostr(linecount));

                            else showmessage(ERROR_PREFIX + 'File is too long');
                        end
                    else // set variables to the read file-variables
                        begin
                            gamefieldList := gamefileGamefieldList;

                            // set players to read variables
                            for i := 0 to PLAYER_COUNT_MAX - 1 do
                                with playerList[i] do
                                    begin
                                        name := gamefilePlayerNames[i];
                                        inventory := gamefilePlayerInventoryList[i];
                                        isAi := gamefilePlayerAIStateList[i];
                                    end;

                            playersTurn := gamefilePlayersTurn;
                            playerCount := gamefilePlayerCount;
                        end;

                    // if reading worked return true
                    readGameSaveToVariables := not badGamefile;
                end;

            function writeVariablesToGameSave(
                filename:string;
                gamefieldList:TGamefileGamefieldList;
                playerList:TPlayerList;
                playersTurn:TPlayersTurn;
                playerCount:integer):boolean;

                var
                    gamefile:textfile;
                    i, j:integer;
                    error:boolean;

                begin
                    error := false;

                    assignfile(gamefile, filename);
                    try
                        rewrite(gamefile);

                        // write variables to file
                        writeln(gamefile, playerCount);

                        // write playernames
                        for i := 0 to playerCount - 2 do
                            write(gamefile, playerList[i].name + ',');
                        writeln(gamefile, playerList[playerCount - 1].name);

                        // write ai-states
                        for i := 0 to playerCount - 2 do
                            write(gamefile, AIStateToString(playerList[i].isAI) + ',');
                        // to write without the comma
                        writeln(gamefile, AIStateToString(playerList[playerCount - 1].isAI));

                        // write gamefield
                        for i := 0 to GAMEFIELD_COLUMNS - 1 do
                            begin
                                for j := 0 to GAMEFIELD_COLUMNS - 1 do
                                    begin
                                        // to write the last without the comma
                                        if (i = GAMEFIELD_COLUMNS - 1) and 
                                            (j = GAMEFIELD_COLUMNS - 1) then
                                            write(gamefile,
                                                integer(gamefieldList[i, j]))
                                        else write(gamefile,
                                            inttostr(integer(gamefieldList[i, j])) + ',');
                                    end;
                                writeln(gamefile);
                            end;
                        
                        // write inventory
                        for i := 0 to playerCount - 1 do
                            begin
                                for j := 0 to INVENTORY_MAX - 2 do
                                    begin
                                        write(gamefile,
                                            inttostr(integer(playerList[i].inventory[j])) +
                                            ',');
                                    end;
                                // to write without the comma
                                writeln(gamefile, integer(playerList[i].inventory[INVENTORY_MAX - 1]));
                            end;
                        
                        writeln(gamefile, integer(playersTurn));

                        // todo highlighted inventory
                        writeln(gamefile, 0);

                        // todo action-stone counter
                        // only write -> no new line
                        write(gamefile, '0,0,0,0');

                        closefile(gamefile);
                    // when something went wrong set error
                    except
                        error := true;
                    end;

                    writeVariablesToGameSave := error;
                end;
    end.