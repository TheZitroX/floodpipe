{
    file:       UPixelFunctions.pas
    author:     John Lienau
    title:      Generates pictures and styles them
    version:    v1.0
    date:       03.08.2022
    copyright:  Copyright (c) 2022
}

unit UPixelFunctions;

    // Bitmap file with all tiles in a 4 by 4 (à 58px) grid
    {$R resources/pipesEmptyTilemap.RES}
    {$R resources/pipesWaterTilemap.RES}
    {$R resources/wallsTilemap.RES}

interface
    uses
        sysutils, vcl.graphics, system.classes, system.types,

        UTypedefine, UProperties;

procedure loadPictureFromBitmap(var cell:TCell);

implementation

    {
        @brief  gets a selected tile from the tilemapBitmap
        @param  tilemapBitmap the resource
                cellItem the item
                cellRotation selects the rotated variant of cellItem
        @return the tile as TBitmap
    }
    function getTileFromTilemap(
        tilemapBitmap:TBitmap;
        cellItem:TCellItem;
        cellRotation:TCellRotation):TBitmap;
    var
        tileBitmap:TBitmap;
        posX, posY:integer;
    begin
        tileBitmap := TBitmap.Create();
        tileBitmap.PixelFormat := PIXEL_FORMAT;
        tileBitmap.Width := TILEMAP_TILE_SIDE_LENGTH;
        tileBitmap.Height := TILEMAP_TILE_SIDE_LENGTH;

        // case cellItem of
        //     else begin
                posX := TILEMAP_TILE_SIDE_LENGTH * integer(cellRotation);
                posY := TILEMAP_TILE_SIDE_LENGTH * integer(cellItem);
            // end;
        // end;
        
        tileBitmap.Canvas.CopyRect(
            Rect(0, 0, TILEMAP_TILE_SIDE_LENGTH, TILEMAP_TILE_SIDE_LENGTH),
            tilemapBitmap.Canvas,
            Rect(posX, posY, posX + TILEMAP_TILE_SIDE_LENGTH, posY + TILEMAP_TILE_SIDE_LENGTH));

        getTileFromTilemap := tileBitmap;
    end;

    {
        @brief  loads a tile from the tilemapResource to the picture
        @param resource-bitmap the ressource bitmap
                tileIndex the selected tile
    }
    procedure loadPictureFromBitmap(var cell:TCell);
    var
        stream:TResourceStream;
        tilemapBitmap:TBitmap;
        resourceStreamSource:string;
    begin
        tilemapBitmap := TBitmap.Create();
        if not (cell.cellType = TCellType.TYPE_NONE) then begin
            try
                tilemapBitmap.PixelFormat := PIXEL_FORMAT;

                // get the right tilemap
                case cell.cellType of
                    TYPE_WALL: resourceStreamSource := 'walls';
                    TYPE_PIPE: resourceStreamSource := 'pipes';
                    else assert(true, 'ERROR from UPixelFunctions: no such TCellType');
                end;

                // if a pipe then add the content of a pipe
                if (cell.cellType = TCellType.TYPE_PIPE) then
                    case cell.cellContent of
                        CONTENT_EMPTY: resourceStreamSource := resourceStreamSource + 'Empty';
                        CONTENT_WATER: resourceStreamSource := resourceStreamSource + 'Water';
                        else assert(true, 'ERROR from UPixelFunctions: no such TCellContent');
                    end;

                resourceStreamSource := resourceStreamSource + 'Tilemap';
                
                // load the stream from resourceStreamSource
                stream := TResourceStream.Create(HInstance, resourceStreamSource, RT_RCDATA);

                try
                    // load bitmap from resource
                    tilemapBitmap.LoadFromStream(stream);
                    // use this when debuging the image resource
                    //// tilemapBitmap.LoadFromFile('tilemap.bmp');
                    cell.image.Picture.Bitmap := getTileFromTilemap(
                        tilemapBitmap,
                        cell.cellItem,
                        cell.cellRotation
                    );
                finally
                    stream.free;
                end;
            finally
                tilemapBitmap.free;
            end;
            cell.image.visible := true;
        end else begin
            cell.image.visible := false;
        end;
    end;

    {
        @brief  will darken the bitmap and put a red rectangle around

        @param bitmap as TBitmap
        @return changed-bitmp as TBitmap
    }
    function bitmapToClickedBitmap(
        bitmap:TBitmap):TBitmap;
    type
        TPixelArray = array[0..2] of Byte;
    var
        p:^TPixelArray;
        i, j:integer;
    begin
        for i := 0 to bitmap.Height - 1 do begin
            p := bitmap.ScanLine[i];
            for j := 0 to bitmap.Width - 1 do begin
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
