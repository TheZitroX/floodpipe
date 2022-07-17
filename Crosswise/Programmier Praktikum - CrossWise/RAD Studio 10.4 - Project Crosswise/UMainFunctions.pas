{
  file:			UMainFunctions.pas
  title:		Crosswise - functions
  author:		John Lienau (yourmom@ctemplar.com)
  version:		1.0
  date:			04.06.2022
  copyright:	Copyright (c) 2022

  brief:		functions used in UMain.
}

unit UMainFunctions;

    interface

    uses
        Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
        System.Classes, Vcl.Graphics,
        Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,

        UMainTypeDefine, UProperties, UPixelFunctions;
    
    // public functions
    function getXFromGamefieldName(name:string):integer;
    function getYFromGamefieldName(name:string):integer;
    function getStatusFromGamefieldName(name:string):TItemEnum;
    procedure setGamefieldImageToNameState(var gamefield:TGamefield);
    procedure setGamefieldNameStatus(var gamefield:TGamefield; newState:integer);
    procedure setPictureFromItem(var gamefield:TGamefield; item:TItemEnum);
    function isGamefieldType(field:TGamefield):boolean;
    procedure setGamefieldImgeToHighlighted(var gamefield:TGamefield);
    procedure setGamefieldsStateFromGamefieldList(var gamefields:TGamefields; gamefieldList:TGamefileGamefieldList);
    procedure setPlayerInventoryFromPlayerList(var playerfields:TPlayerfields; playerList:TPlayerList);
    procedure setPlayerCaptionFromPlayerList(var playerNameTagList:TStaticNameTagList; playerList:TPlayerList);

    implementation

        {
            @brief  to get the x-integer-value of the gamefield-name
                    (exmp.) name = c0x1y4
                            -> x = 1

            @param name is the gamefield-name
            @return x as integer
        }
        function getXFromGamefieldName(name:string):integer;
            var
                posX, posY:integer;

            begin
                posX := pos('x', name) + 1;
                posY := pos('y', name);
                getXFromGamefieldName := strtoint(copy(name, posX, posY - posX));
            end;

        {
            @brief  to get the y-integer-value of the gamefield-name
                    (exmp.) name = c0x1y4
                            -> y = 4

            @param name is the gamefield-name
            @return y as integer
        }
        function getYFromGamefieldName(name:string):integer;
            var
                posY:integer;
            
            begin
                posY := pos('y', name) + 1;
                getYFromGamefieldName := strtoint(copy(name, posY));
            end;


        {
            @brief  to get the status of the gamefield-name
                    (exmp.) name = c0x1y4
                        -> status= 0 = FIELD_EMTY

            @param name is the gamefield-name
            @return c as char
        }
        function getStatusFromGamefieldName(name:string):TItemEnum;
            var
                c, posC, posX:integer;

            begin
                posC := pos('c', name) + 1;
                posX := pos('x', name);
                c := strtoint(copy(name, posC, posX - posC));

                getStatusFromGamefieldName := TItemEnum(c);
            end;

        {
            @brief  to set the state of a gamefield in his name
                    (exmp.) name = c0x1y4
                        -> status= 0 = FIELD_EMTY

            @param  gamefield as TGamefiled
                    newState as TItemEnum
        }
        procedure setGamefieldNameStatus(var gamefield:TGamefield; newState:integer);
            var
                posC, posX:integer;
                name:string;

            begin
                name := gamefield.name;

                posC := pos('c', name) + 1;
                posX := pos('x', name);
                delete(name, posC, posX - posC);
                insert(inttostr(newState), name, posC);

                gamefield.name := name;
            end;

        {
            @brief  to set a Pucture from TItemEnum

            @param  gamefield as TGamefiled
                    item as TItemEnum
        }
        procedure setPictureFromItem(var gamefield:TGamefield; item:TItemEnum);
            begin
                // with gamefield do
                    if (integer(item) > integer(FIELD_TAKE_BACK)) then showmessage('faked');
                    loadPictureFromBitmap(gamefield, item);
                    // case item of
                    // // fix to image2.Picture.Bitmap.Assign(image1.Picture.bitmap)
                    //     FIELD_EMTY: Picture.LoadFromFile(TILE_TEST);
                    //     FIELD_RED: Picture.LoadFromFile(TILE_RED);
                    //     FIELD_BLUE: Picture.LoadFromFile(TILE_BLUE);
                    //     FIELD_GREEN: Picture.LoadFromFile(TILE_GREEN);
                    //     FIELD_ORANGE: Picture.LoadFromFile(TILE_ORANGE);
                    //     FIELD_MAGENTA: Picture.LoadFromFile(TILE_MAGENTA);
                    //     FIELD_YELLOW: Picture.LoadFromFile(TILE_YELLOW);

                    //     else Picture.LoadFromFile(TILE_PLAYERFIELD_EMTY);
                    // end;
            end;

        {
            @brief  to set the image of the gamefield-name

            @param  gamefield as TGamefield
        }
        procedure setGamefieldImageToNameState(var gamefield:TGamefield);
            begin
                setPictureFromItem(gamefield, getStatusFromGamefieldName(gamefield.name));
            end;

        {
            @brief  to get the Type of gamefield
                    (gamefield or playerfield (inventory))

            @param  gamefield as TGamefield
            @return boolean (true if its a gamefield)
        }
        function isGamefieldType(field:TGamefield):boolean;
            begin
                isGamefieldType := field.name[1] = 'c';
            end;

        {
            @brief  to set the playerfield as the item

            @param  gamefield as TGamefield
                    item as TItemEnum
        }
        procedure setGamefieldImgeToHighlighted(var gamefield:TGamefield);
            var
                bitmap:TBitmap;

            begin
                with gamefield do
                    Picture.bitmap := bitmapToClickedBitmap(Picture.bitmap);
            end;

        {
            @brief  to set all gamefields to the gamefieldList

            @param  gamefields as TGamefields
                    gmefieldList as TGamefileGamefieldList
        }
        procedure setGamefieldsStateFromGamefieldList(var gamefields:TGamefields; gamefieldList:TGamefileGamefieldList);
            var
                i,j:integer;
                
            begin
                for i := 0 to GAMEFIELD_COLUMNS - 1 do
                    for j := 0 to GAMEFIELD_COLUMNS - 1 do
                        begin
                            setGamefieldNameStatus(gamefields[i, j], integer(gamefieldList[i, j]));
                            setGamefieldImageToNameState(gamefields[i, j]);
                        end;
            end;

        {
            @brief  set the playerfields to the inventoryList item

            @param  playerfields as TPlayerfields
                    playerList as TPlayerList
        }
        procedure setPlayerInventoryFromPlayerList(var playerfields:TPlayerfields; playerList:TPlayerList);
            var
                i,j:integer;

            begin
                for i := 0 to PLAYER_COUNT_MAX - 1 do
                    begin
                        // set inventory
                        for j := 0 to INVENTORY_MAX - 1 do
                            begin
                                setPictureFromItem(playerfields[i, j], playerList[i].inventory[j]);
                            end;
                    end;
            end;

        procedure setPlayerCaptionFromPlayerList(var playerNameTagList:TStaticNameTagList; playerList:TPlayerList);
            var
                i:integer;
            
            begin
                for i := 0 to PLAYER_COUNT_MAX - 1 do
                    playerNameTagList[i].Caption := playerList[i].Name;
            end;
    end.       
