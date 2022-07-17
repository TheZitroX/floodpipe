{
  file:			UMainTypeDefine.pas
  title:		Types for Crosswise
  author:		John Lienau (yourmom@ctemplar.com)
  version:		1.0
  date:		    04.06.2022
  copyright:	Copyright (c) 2022

  brief:		Types used in UMain. Dont change!
}

unit UMainTypeDefine;
    interface
        uses
            sysutils, UProperties, Vcl.ExtCtrls, Vcl.StdCtrls;

        type
            // item list
            // fix to TStone ist: stNone, stBlue, stGreen, stOrange, stPink, stPurple, stYellow, stMove, stSwitchField, stSwitchHand, stTakeBack)
            TItemEnum = (   FIELD_EMTY = 0,
                            FIELD_BLUE = 1,
                            FIELD_GREEN = 2,
                            FIELD_ORANGE = 3,
                            FIELD_MAGENTA = 4,
                            FIELD_RED = 5,
                            FIELD_YELLOW = 6,
                            FIELD_MOVE,
                            FIELD_SWITCH_FIELD,
                            FIELD_SWITCH_HAND,
                            FIELD_TAKE_BACK);

            // gamefields
                // gamefield
                TGamefield = TImage;

                // optimize TPanel -> structure for more flexebillity (state-info etc.)
                //                      x - axis                    y - axis
                TGamefields = array[0..GAMEFIELD_COLUMNS - 1, 0..GAMEFIELD_COLUMNS - 1] of TGamefield;

            // player
                // inventory
                TPlayerInventory = array [0..INVENTORY_MAX - 1] of TItemEnum;

                // player record
                TPlayer = record
                        name:string;
                        isAI:boolean;
                        inventory:TPlayerInventory; 
                        points:integer;
                    end;
                
                // playerlist
                TPlayerList = array [0..PLAYER_COUNT_MAX - 1] of TPlayer;

                // Name Tags
                TStaticNameTagList = array [0..PLAYER_COUNT_MAX - 1] of TStaticText;
                
                // what player has the turn
                TPlayersTurn = (    PLAYER_ONE = 1,
                                    PLAYER_TWO = 2,
                                    PLAYER_THREE = 3,
                                    PLAYER_FOUR = 4);

            // Player Inventory
                // visuel Inventory
                TPlayerfields = array[0..PLAYER_COUNT_MAX - 1, 0..INVENTORY_MAX - 1] of TGamefield;

                // selected item
                TSelectedItem = integer;

            // GAMEFILE
                // used for tempstore the playernames
                TGamefilePlayerNameList = array[0..PLAYER_COUNT_MAX - 1] of string;
                TGamefilePlayerAIStateList = array[0..PLAYER_COUNT_MAX - 1] of boolean;
                TGamefileGamefieldList = array[0..GAMEFIELD_COLUMNS - 1, 0..GAMEFIELD_COLUMNS - 1] of TItemEnum;
                TGamefilePlayerInventoryList = array[0..PLAYER_COUNT_MAX - 1] of TPlayerInventory;
    implementation
    end.