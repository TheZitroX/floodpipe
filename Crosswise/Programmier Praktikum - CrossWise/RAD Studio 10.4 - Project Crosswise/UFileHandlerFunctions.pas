{
  file:			UFileHandlerFunctions.pas
  title:		Many functions for FileHandler
  author:		John Lienau (yourmom@ctemplar.com)
  version:		v1.0
  date:			05.06.2022
  copyright:	Copyright (c) 2022

  brief:		// todo
}

unit UFileHandlerFunctions;

    interface

        uses
            sysutils, Vcl.Dialogs,

            UProperties, UMainTypeDefine;

        function getNumberFromString(str:string):integer;
        function readStringWithoutCommaFromGamefileLine(var gamefileLine:string; var stringWithoutComma:string):boolean;
        function readPlayerNamesFromGamefileLine(gamefileLine:string; var gamefilePlayerNames:TGamefilePlayerNameList):boolean;
        function readPlayerAIStateFromGamefileLine(gamefileLine:string; var gamefilePlayerAIStateList:TGamefilePlayerAIStateList):boolean;
        function readGamefieldFromGamefileLine(var gamefileLine:string; var gamefileGamefield:TItemEnum):boolean;
        function readItemFromGamefileLine(var gamefileLine:string; var item:TItemEnum):boolean;
        function getPlayersTurnFromGamefileLine(gamefileLine:string; var playersTurn:TPlayersTurn):boolean;
        function AIStateToString(AIState:boolean):string;

        implementation
            
            {
                @brief  is used to get and check for integer number in string

                @param str as string
                @return integer where -1 equals not a PlayerCount num
            }
            function getNumberFromString(str:string):integer;
                var
                    isANum:boolean;
                    num:integer;

                begin
                    // pos of $ is used to cut out HEX values
                    isANum := (pos('$', str) = 0) and trystrtoint(str, num);

                    if isANum then 
                        getNumberFromString := num
                    else getNumberFromString := -1;
                end;

            {
                @brief  get a substringstring seperated from ',' of the gamefileLine.
                        function will delete that substring with ',' from that string!
                        only works with a ',' after the substring!

                @param gamefileLine as string IN and OUT
                    stringWithoutComma as string IN and OUT
                @return boolean false as worked and true as an error eccured
            }
            function readStringWithoutCommaFromGamefileLine(var gamefileLine:string; var stringWithoutComma:string):boolean;
                var
                    posComma:integer;
                    badGamefileLine:boolean;

                begin
                    posComma := 0;

                    // check if gamefileLine is okay to read;
                    if length(gamefileLine) > 0 then
                        begin
                            posComma := pos(',', gamefileLine);
                            badGamefileLine := posComma = 1;
                        end
                    else
                        badGamefileLine := true;

                    if not badGamefileLine then
                        if posComma > 1 then
                            begin
                                stringWithoutComma := copy(gamefileLine, 1, posComma - 1);
                                // delete the name with comma
                                delete(gamefileLine, 1, posComma);
                            end
                        else
                            stringWithoutComma := gamefileLine;

                    readStringWithoutCommaFromGamefileLine := badGamefileLine;
                end;

            {
                @brief  to get the names of the *.cwd file to a name array

                @param gamefileLine as string IN and OUT
                        gamefilePlayerNames as TGamefilePlayerNameList IN and OUT
                @return boolean false as worked and true as an error eccured
            }
            function readPlayerNamesFromGamefileLine(gamefileLine:string; var gamefilePlayerNames:TGamefilePlayerNameList):boolean;

                var
                    i:integer;
                    badGamefileLine:boolean;

                begin
                    badGamefileLine := false;

                    i := 0;
                    while (not badGamefileLine) and (i < PLAYER_COUNT_MAX) do
                        begin
                            if not badGamefileLine then
                                badGamefileLine := readStringWithoutCommaFromGamefileLine(gamefileLine, gamefilePlayerNames[i]);

                            // go to next name
                            inc(i);
                        end;

                    readPlayerNamesFromGamefileLine := badGamefileLine;
                end;

            {
                @brief  to get the player AI state form a gamefileLine

                @param gamefileLine as string
                        gamefilePlayerAIStateList as TGamefilePlayerAIStateList IN and OUT
                @return boolean true as worked and false as an error eccured
            }
            function readPlayerAIStateFromGamefileLine(gamefileLine:string; var gamefilePlayerAIStateList:TGamefilePlayerAIStateList):boolean;

                {
                    @brief  to set the AI state of the inputstring

                    @param tempAIStateString as string
                            gamefilePlayerAIState as boolean IN and OUT
                    @return boolean true as an error eccured and false succsess
                }
                function readPlayerAIStateFromSubString(tempAIStateString:string; var gamefilePlayerAIState:boolean):boolean;
                    var
                        badGamefileLine:boolean;

                    begin
                        badGamefileLine := not (length(tempAIStateString) = 1);
                        if not badGamefileLine then
                            begin
                                if tempAIStateString = 'J' then
                                    gamefilePlayerAIState := true
                                else if tempAIStateString = 'N' then
                                    gamefilePlayerAIState := false
                                else badGamefileLine := true;
                            end;

                        readPlayerAIStateFromSubString := badGamefileLine;
                    end;

                var
                    i:integer;
                    badGamefileLine:boolean;
                    tempAIStateString:string;
                    
                begin
                    badGamefileLine := false;

                    i := 0;
                    while (i < PLAYER_COUNT_MAX) and not badGamefileLine do
                        begin
                            badGamefileLine := readStringWithoutCommaFromGamefileLine(gamefileLine, tempAIStateString);
                            if not badGamefileLine then
                                badGamefileLine := readPlayerAIStateFromSubString(tempAIStateString, gamefilePlayerAIStateList[i]);
                            
                            // go to next element
                            inc(i);
                        end;

                    readPlayerAIStateFromGamefileLine := badGamefileLine;
                end;

            // todo Inlinedoku
            function readGamefieldFromGamefileLine(var gamefileLine:string; var gamefileGamefield:TItemEnum):boolean;
                var
                    subString:string;
                    badGamefileLine:boolean;
                    number:integer;
                    
                begin
                    badGamefileLine := readStringWithoutCommaFromGamefileLine(gamefileLine, subString);
                    if not badGamefileLine then
                        begin
                            number := getNumberFromString(subString);
                            // check if item is in gamefield range (0..6)
                            badGamefileLine := (number < ITEM_ID_MIN) or (number > ITEM_ID_MAX);
                            if not badGamefileLine then
                                gamefileGamefield := TItemEnum(number);
                        end;

                    readGamefieldFromGamefileLine := badGamefileLine;
                end;

            // todo inlinedoku
            function readItemFromGamefileLine(var gamefileLine:string; var item:TItemEnum):boolean;
                var
                    subString:string;
                    badGamefileLine:boolean;
                    number:integer;
                
                begin
                    badGamefileLine := readStringWithoutCommaFromGamefileLine(gamefileLIne, subString);
                    if not badGamefileLine then
                        begin
                            number := getNumberFromString(subString);
                            // check if item is in TItemEnum range
                            badGamefileLine := (number < 0) or (number > 10);
                            if not badGamefileLine then
                                item := TItemEnum(number);
                        end;
                    
                    readItemFromGamefileLine := badGamefileLine;
                end;

            // todo hadder
            function getPlayersTurnFromGamefileLine(gamefileLine:string; var playersTurn:TPlayersTurn):boolean;
                var
                    badGamefileLine:boolean;
                    number:integer;

                begin
                    number := getNumberFromString(gamefileLine);
                    // if not gamemode 2 or 4 players then its bad
                    badGamefileline := (number < 1) and (number > 4);
                    if not badGamefileLine then
                        playersTurn := TPlayersTurn(number);

                    getPlayersTurnFromGamefileLine := badGamefileLine;
                end;
            
            {
                @brief  Gives a symbol ('J' or 'N')

                @param AIState as boolean
                @return string if AIState then 'J' else 'N'
            }
            function AIStateToString(AIState:boolean):string;
                begin
                    if AIState then
                        AIStateToString := 'J'
                    else
                        AIStateToString := 'N';
                end;
    end.