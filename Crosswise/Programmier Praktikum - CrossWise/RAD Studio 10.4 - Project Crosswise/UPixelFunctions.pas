{
  file:			UPixelFunctions.pas
  title:		Crosswise - PixelFunctions
  author:		John Lienau (yourmom@ctemplar.com)
  version:		1.0
  date:			29.05.2022
  copyright:	Copyright (c) 2022

  brief:		Functions to Highlight, Dim, Set and load Bitmaps
}

unit UPixelFunctions;

    // Bitmap file with all tiles in a 4 by 4 (à 58px) grid
    {$R tilemapResource.RES}

    interface

        uses
            sysutils, Vcl.graphics, UMainTypeDefine, UProperties, System.Classes, System.Types;

        function bitmapToClickedBitmap(bitmap:TBitmap):TBitmap;
        procedure loadPictureFromBitmap(var gamefield:TGamefield; item:TItemEnum);

        implementation
            const
                // resource
                    // size
                        TILEMAP_TILE_LENGTH = 58;
                        TILEMAP_TILES_COLUMNS = 4;
                        TILEMAP_TILES_ROWS = 4;

            {
                @brief  gets a selected tile from the tilemapBitmap
                @param tilemapBitmap as TBitmap
                        item as TItemEnum
                @return the tile as TBitmap
            }
            function getTileFromTilemap(tilemapBitmap:TBitmap; item:TItemEnum):TBitmap;
                var
                    tileBitmap:TBitmap;
                    posX, posY:integer;

                begin
                    tileBitmap := TBitmap.Create();
                    tileBitmap.PixelFormat := PIXEL_FORMAT;
                    tileBitmap.Width := TILEMAP_TILE_LENGTH;
                    tileBitmap.Height := TILEMAP_TILE_LENGTH;

                    posX := TILEMAP_TILE_LENGTH * (integer(item) mod 4);
                    posY := TILEMAP_TILE_LENGTH * (integer(item) div 4);
                    
                    tileBitmap.Canvas.CopyRect(
                        Rect(0, 0, TILEMAP_TILE_LENGTH, TILEMAP_TILE_LENGTH),
                        tilemapBitmap.Canvas,
                        Rect(posX, posY, posX + TILEMAP_TILE_LENGTH, posY + TILEMAP_TILE_LENGTH));

                    getTileFromTilemap := tileBitmap;
                end;

            {
                @brief  loads a tile from the tilemapResource to the picture
                @param resource-bitmap the ressource bitmap
                        tileIndex the selected tile
            }
            procedure loadPictureFromBitmap(var gamefield:TGamefield; item:TItemEnum);
                var
                    stream:TResourceStream;
                    tilemapBitmap:TBitmap;

                begin
                    tilemapBitmap := TBitmap.Create();
                    tilemapBitmap.PixelFormat := PIXEL_FORMAT;
                    try
                        stream := TResourceStream.Create(HInstance, 'tilemapResource', RT_RCDATA);
                        try
                            // load bitmap from resource
                            tilemapBitmap.LoadFromStream(stream);
                            // use this when debuging the image resource
                            //// tilemapBitmap.LoadFromFile('tilemap.bmp');
                            gamefield.Picture.Bitmap := getTileFromTilemap(tilemapBitmap, item);
                        finally
                            stream.free;
                        end;
                    finally
                       tilemapBitmap.free;
                    end;
                    
                end;

            {
                @brief  will darken the bitmap and put a red rectangle around

                @param bitmap as TBitmap
                @return changed-bitmp as TBitmap
            }
            function bitmapToClickedBitmap(bitmap:TBitmap):TBitmap;
                type
                    TPixelArray = array[0..2] of Byte;

                var
                    p:^TPixelArray;
                    i, j:integer;

                begin
                    for i := 0 to bitmap.Height - 1 do
                        begin
                            p := bitmap.ScanLine[i];
                            for j := 0 to bitmap.Width - 1 do
                                begin
                                    // darken all pixel by half of value
                                    p^[0] := byte(p^[0] div 2);
                                    p^[1] := byte(p^[1] div 2);
                                    p^[2] := byte(p^[2] div 2);

                                    // go to next pixel-set
                                    inc(p);
                                end;
                        end;
                    
                    bitmapToClickedBitmap := bitmap;
                end;
        end.