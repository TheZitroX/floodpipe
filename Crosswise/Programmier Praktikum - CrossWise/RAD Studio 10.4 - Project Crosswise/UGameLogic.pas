{
  file:			UGameLogic.pas
  title:		Crosswise - Gamelogic
  author:		John Lienau (yourmom@ctemplar.com)
  version:		1.0
  date:			04.06.2022
  copyright:	Copyright (c) 2022

  brief:		// todo
}


unit UGameLogic;

    interface

        uses
            Vcl.Dialogs, System.sysutils,
            UMainTypeDefine, UProperties, UMainFunctions;

        procedure checkGamefield(gamefields:TGamefields; var playerList:TPlayerList);

        type
            // used to count the colors on the gamefield
            TColorCounter = array[1..6] of integer;
            
        implementation

            // todo hadder
            procedure checkGamefield(gamefields:TGamefields; var playerList:TPlayerList);
                {
                    @brief  checks the colorCounter for point cases

                            when all colors are given,
                            the gameWonByHorizontal returns true.

                    @param  colorCounter as TColorCounter
                            gameWonByHorizontal as boolean

                    @return the points as integer;
                }
                function checkPointsFromColorCounter(colorCounter:TColorCounter; var gameWonByHorizontal:boolean):integer; var i:integer;
                        pointCounter, point:integer;
                        specialColorCaseCounter:integer; // just used to check if all fields has been filled with a color

                    begin
                        pointCounter := 0;
                        specialColorCaseCounter := 0;

                        // check each color
                        for i := COLOR_LOW to COLOR_HIGH do
                            begin
                                point := 0;
                                case colorCounter[i] of
                                    2:  point := TWO_STONES_MATCHES_POINTS;
                                    3:  point := THREE_STONES_MATCHES_POINTS;
                                    4:  point := FOUR_STONES_MATCHES_POINTS;
                                    5:  point := FIVE_STONES_MATCHES_POINTS;

                                    // case of 6 matching colors, the game is won
                                    6:  begin
                                            point := SIX_STONES_MATCHES_POINTS;
                                            gameWonByHorizontal := true;
                                        end;
                                end;
                                pointCounter := pointCounter + point;

                                specialColorCaseCounter := specialColorCaseCounter + colorCounter[i];
                            end;

                        // for the special rainbow-case
                        if (specialColorCaseCounter = GAMEFIELD_COLUMNS) and (pointCounter = 0) then
                            pointCounter := RAINBOW_STONES_MATCHES_POINTS;

                        checkPointsFromColorCounter := pointCounter;
                    end;

                {
                    @brief  performes a horizontal check through gamefields
                            If a rainbow pattern is found, gameWonByHorizontal returns true

                    @param  gamefields as TGamefields
                            gameWonByHorizontal as boolean

                    @return horizontal points as integer
                }
                function gamefieldHorizontallyPointsCheck(gamefields:TGamefields; var gameWonByHorizontal:boolean):integer;
                    var
                        i, j, k:integer;
                        colorCounter:TColorCounter;
                        pointCounter:integer;
                        gamefieldType:TItemEnum;
                    
                    begin
                        pointCounter := 0;

                        // checking each row
                        for i := 0 to GAMEFIELD_COLUMNS - 1 do
                            begin
                                // set all color counts to 0
                                for k := COLOR_LOW to COLOR_HIGH do
                                    colorCounter[k] := 0;

                                // checking each column
                                for j := 0 to GAMEFIELD_COLUMNS - 1 do
                                    begin
                                        // increment the color when gamefield is a color
                                        gamefieldType := getStatusFromGamefieldName(gamefields[i, j].name);
                                        if (gamefieldType <> FIELD_EMTY) then
                                            inc(colorCounter[integer(gamefieldType)]);
                                    end;

                                pointCounter := pointCounter + checkPointsFromColorCounter(colorCounter, gameWonByHorizontal);
                            end;

                        // for i := 1 to 6 do
                        //     pointCounter := pointCounter + colorCounter[i];

                        gamefieldHorizontallyPointsCheck := pointCounter;
                    end;

                var
                    horizontallyPoints, verticallyPoints:integer;
                    gameWonByHorizontal, gameWonByVertical:boolean;

                begin
                    verticallyPoints := 0;
                    // check horizontal
                    horizontallyPoints := gamefieldHorizontallyPointsCheck(gamefields, gameWonByHorizontal);

                    // showmessage(inttostr(horizontallyPoints));
                end;
        end.