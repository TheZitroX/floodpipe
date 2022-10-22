{
    file:       UProperties.pas
    author:     John Lienau
    title:      Default properties for Floodpipe
    version:    v1.0
    date:       31.07.2022
    copyright:  Copyright (c) 2022

    brief:      Best to not change the values of the constants
}

unit UProperties;
interface
    uses
        sysutils, vcl.graphics;

    const
        // window
        MAIN_FORM_MIN_WIDTH = 800;
        MAIN_FORM_MIN_HEIGHT = 450;
        // aspect ratio 9 / 16
        MAIN_FORM_ASPECT_RATIO = MAIN_FORM_MIN_HEIGHT / MAIN_FORM_MIN_WIDTH;

        // cells
        DEFAULT_CELL_ROW_COUNT = 10;
        DEFAULT_CELL_COLUMN_COUNT = 10;
        DEFAULT_CELL_TICK_RATE = 1; // (in ms)
        
        // walls
        DEFAULT_WALL_PERCENTAGE = 10; // (in %)

        // ===PIXELFUNCTIONS===
        PIXEL_FORMAT = pf24bit;
        // tilemap
        TILEMAP_TILE_SIDE_LENGTH = 16;
        TILEMAP_TILES_ROWS = 4;
        TILEMAP_TILES_COLUMNS = 4;

implementation
end.