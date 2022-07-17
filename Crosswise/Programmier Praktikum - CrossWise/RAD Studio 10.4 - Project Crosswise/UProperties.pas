{
  file:			UProperties.pas
  author:		John Lienau (yourmom@ctemplar.com)
  title:		Properties for Crosswise
  version:		1.0
  date:			05.06.2022
  copyright:	Copyright (c) 2022

  brief:		Constants for the Crosswise game
                Best to not Change them!
}

unit UProperties;
    interface
        uses
            sysutils, Vcl.graphics;

        const
        // properties:
            // window
                // main form
                    MAINFORM_WIDTH = 1000;
                    MAINFORM_HEIGHT = 800;

                // option buttons
                    OPTION_BUTTON_WIDTH = 150;
                    OPTION_BUTTON_HEIGHT = 50;

            // player
                // player panel
                    PLAYER_COUNT_MAX = 4;
                    PLAYER_PANEL_OFFSET = 50;
                    PLAYER_PANEL_VERTICAL_EXTRA_OFFSET = 80;
                    PLAYER_PANEL_COUNT = 4;

                // Nametag
                    PLAYER_NAMETAG_NAME_PREFIX = 'Player: ';
                    PLAYER_NAMETAG_TOP_OFFSET = -20;

            // field
                GAMEFIELD_WIDTH = 400;
                GAMEFIELD_COLUMNS = 6;
                RACTANGLE_WIDTH = GAMEFIELD_WIDTH div GAMEFIELD_COLUMNS;
                PANEL_OFFSET = 2;

            // item
                // itemid range
                    ITEM_ID_MIN = 0;
                    ITEM_ID_MAX = 15;
                // inventory
                    INVENTORY_MAX = 4;
                // limits
                    STONE_MAX = 7;
                    ACTIONSTONE_MAX = 4;
                    COLOR_LOW = 1;
                    COLOR_HIGH = 6;

            // points
                TWO_STONES_MATCHES_POINTS = 1;
                THREE_STONES_MATCHES_POINTS = 3;
                FOUR_STONES_MATCHES_POINTS = 5;
                FIVE_STONES_MATCHES_POINTS = 7;
                SIX_STONES_MATCHES_POINTS = 9;

                RAINBOW_STONES_MATCHES_POINTS = 6;

            // tiles
                // img-path
                    TILE_TEST_HIGHLIGHTED = 'pictures\tiles\gamefieldTestTileHighlighted.png';
                    TILE_TEST = 'pictures\tiles\gamefieldTestTile.png';
                    
                    TILE_RED = 'pictures\tiles\gamefield\tileRed.png';
                    TILE_BLUE = 'pictures\tiles\gamefield\tileBlue.png';
                    TILE_YELLOW = 'pictures\tiles\gamefield\tileYellow.png';
                    TILE_GREEN = 'pictures\tiles\gamefield\tileGreen.png';
                    TILE_ORANGE = 'pictures\tiles\gamefield\tileOrange.png';
                    TILE_MAGENTA = 'pictures\tiles\gamefield\tileMagenta.png';

                // inventory img-path
                    TILE_PLAYERFIELD_EMTY = 'pictures\tiles\playerfield\playerfieldEmty.png';

            // image
                // background img
                    GAMEFIELD_BACKGROUND = 'pictures\gamefieldbackground.png';
                    PIXEL_FORMAT = pf24bit;

            // SOUNDS
                // packs
                    SOUND_SOUNDPACK_STANDARD = 'standard';

                // sounds
                    SOUND_SOUNDPACK = 'sounds\' + SOUND_SOUNDPACK_STANDARD;
                    SOUND_MOVE = SOUND_SOUNDPACK + '\move.wav';
                    SOUND_GAME_START = SOUND_SOUNDPACK + '\gameStart.wav';
            
            // FileHandler
                // file
                    GAME_FILE_TYPE = '.cwd';
                    GAME_FILE_DEFAULT_DIR = '\gameSaves';

                    GAMEFIELD_LINE_START_IN_FILE = 4;
                    PLAYER_INVENTORY_LINE_START_IN_FILE = 10;
    implementation
    end.