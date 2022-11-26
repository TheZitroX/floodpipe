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

    {
        loads a tile from the tilemapResource to a cell 
        loads the tile from the cells type

        @param  IN/OUT  cell: the targetcell
    }
    procedure loadPictureFromBitmap(var cell:TCell);

implementation

    {
        gets a selected tile from the tilemapBitmap and writes it to tileBitmap

        @param  IN/OUT  tileBitmap: writes the tile to it

                IN      tilemapBitmap: the resource
                        cellItem: the item
                        cellRotation: selects the rotated variant of cellItem
    }
    procedure getTileFromTilemap(
        tilemapBitmap:TBitmap;
        tileBitmap:TBitmap;
        cellItem:TCellItem;
        cellRotation:TCellRotation
    );
    var posX, posY:integer;
    begin
        tileBitmap.PixelFormat := PIXEL_FORMAT;
        tileBitmap.Width := TILEMAP_TILE_SIDE_LENGTH;
        tileBitmap.Height := TILEMAP_TILE_SIDE_LENGTH;

        posX := TILEMAP_TILE_SIDE_LENGTH * integer(cellRotation);
        posY := TILEMAP_TILE_SIDE_LENGTH * integer(cellItem);
        
        tileBitmap.Canvas.CopyRect(
            Rect(0, 0, TILEMAP_TILE_SIDE_LENGTH, TILEMAP_TILE_SIDE_LENGTH),
            tilemapBitmap.Canvas,
            Rect(posX, posY, posX + TILEMAP_TILE_SIDE_LENGTH, posY + TILEMAP_TILE_SIDE_LENGTH)
        );
    end;

    procedure loadPictureFromBitmap(var cell:TCell);
    var
        stream:TResourceStream;
        tilemapBitmap:TBitmap;
        resourceStreamSource:string;
    begin
        if not (cell.cellType = TCellType.TYPE_NONE) then
        begin
            tilemapBitmap := nil;
            resourceStreamSource := '';

            try
                tilemapBitmap := TBitmap.Create();
                tilemapBitmap.PixelFormat := PIXEL_FORMAT;

                // get the right tilemap
                case cell.cellType of
                    TYPE_WALL: resourceStreamSource := 'walls';

                    TYPE_PIPE:
                    begin
                        resourceStreamSource := 'pipes';
                        case cell.cellContent of
                            CONTENT_EMPTY: resourceStreamSource := resourceStreamSource + 'Empty';
                            CONTENT_WATER: resourceStreamSource := resourceStreamSource + 'Water';
                            else assert(false, 'ERROR from UPixelFunctions: no such TCellContent');
                        end;
                    end;

                    else assert(false, 'ERROR from UPixelFunctions: no such TCellType');
                end;

                resourceStreamSource := resourceStreamSource + 'Tilemap';
                
                // load the stream from resourceStreamSource
                stream := TResourceStream.Create(HInstance, resourceStreamSource, RT_RCDATA);

                try
                    // load bitmap from resource
                    tilemapBitmap.LoadFromStream(stream);
                    // use this when debuging the image resource
                    //// tilemapBitmap.LoadFromFile('tilemap.bmp');
                    getTileFromTilemap(
                        tilemapBitmap,
                        cell.image.Picture.Bitmap,
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
        end
        else
        begin
            cell.image.visible := false;
        end;
    end;
end.
