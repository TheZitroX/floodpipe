{
    file:       UProperties.pas
    author:     John Lienau
    title:      Default properties for Floodpipe
    version:    v1.0
    date:       31.07.2022
    copyright:  Copyright (c) 2022

    brief:      Best to not change the values of the constants in this file.
                If you do, you will have to recompile the entire project.
                On your own risk! I am not responsible for any damage caused by changing the values in this file.
}

unit UProperties;
interface
    uses
        sysutils, vcl.graphics;

    const
        MAIN_FORM_MIN_WIDTH = 800; // (in px)
        MAIN_FORM_MIN_HEIGHT = 450; // (in px)

        // aspect ratio 9 / 16 = 0.5625 (in px)
        MAIN_FORM_ASPECT_RATIO = MAIN_FORM_MIN_HEIGHT / MAIN_FORM_MIN_WIDTH;

        // cells
        DEFAULT_CELL_ROW_COUNT = 10;
        DEFAULT_CELL_COLUMN_COUNT = 10;
        DEFAULT_CELL_TICK_RATE = 1; // (in ms)
        
        // walls (in %)
        DEFAULT_WALL_PERCENTAGE = 10;

        // ===PIXELFUNCTIONS===
        PIXEL_FORMAT = pf24bit; // pixel format
        // tilemap
        TILEMAP_TILE_SIDE_LENGTH = 16;
        TILEMAP_TILES_ROWS = 4;
        TILEMAP_TILES_COLUMNS = 4;

implementation
    // nothing to see here, move along
end.