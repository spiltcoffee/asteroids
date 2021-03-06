//=============================================================================
// sgTileMap.pas
//=============================================================================
//
// Responsible for loading and processing a "Mappy" data file exported using
// the Lua script specifically written for SwinGame to create map files.
//
// Change History:
//
// Version 3.0:
// - 2009-07-13: Clinton: Renamed Event to Tag - see types for more details
// - 2009-07-10: Andrew : Added missing const modifier for struct parameters
// - 2009-07-09: Clinton: Optimized IsPointInTile slightly (isometric)
//                        Optimized GetTileFromPoint (isometric)
// - 2009-07-08: Clinton: Code comments, TODO notes and some tweaks/optimization
// - 2009-06-22: Clinton: Comment format, cleanup and new additions.
// - 2009-06-17: Andrew : added meta tags, renamed from "mappy" to tilemap
//
// Version 2:
// - 2008-12-17: Andrew : Moved all integers to LongInt
//
// Version 1.1.5:
// - 2008-04-18: Andrew : Fix extensions to work with Delphi.
//
// Version 1.1:
// - 2008-04-02: Stephen: Added MapWidth(), MapHeight(), BlockWidth(),
//                        BlockHeight(), GapX(), GapY(), StaggerX(), StaggerY(),
//                        LoadIsometricInformation(), LoadMapv2(),
//                      : various bug fixes
// - 2008-04-02: Andrew : Removed gap loading as mappy support has not been
//                        updated on the web, and this version is unable to
//                        read the old files.
// - 2008-03-29: Stephen: MapData record now contains GapX, GapY, StaggerX,
//                        StaggerY, Isometric
//                      : LoadMapInformation, now loads the new isometric related data
//                      : DrawMap now draws isometric tiles with their correct offsets
// - 2008-01-30: Andrew : Added const to vector param, increased search for collision tests
// - 2008-01-25: Andrew : Fixed compiler hints
// - 2008-01-22: Andrew : Re-added CollidedWithMap to allow compatibility with 1.0
// - 2008-01-21: Stephen: CollidedWithMap replaced with 3 Routines,
//                        - HasSpriteCollidedWithTile,
//                        - MoveSpriteOutOfTile,
//                        - WillCollideOnSide
// - 2008-01-17: Aki + Andrew: Refactor
//
// Version 1.0:
// - Various
//=============================================================================

///@module TileMap
///@static
unit sgTileMap;

//=============================================================================
interface
//=============================================================================

  uses  sgTypes;

  /// @lib
  /// @class Map
  /// @method Draw
  procedure DrawMap(m: Map);

  /// @lib
  /// @class Map
  /// @method HasSpriteCollidedWithTile
  function SpriteHasCollidedWithTile(m: Map; s: Sprite): Boolean; overload;

  /// @lib SpriteHasCollidedWithTileOutXY
  /// @class Map
  /// @overload  HasSpriteCollidedWithTile HasSpriteCollidedWithTileOutXY
  function SpriteHasCollidedWithTile(m: Map; s: Sprite; out collidedX, collidedY: LongInt): Boolean; overload;

  /// @lib
  /// @class Map
  /// @method WillCollideOnSide
  function WillCollideOnSide(m: Map; s: Sprite): CollisionSide;

  /// @lib
  /// @class Map
  /// @method MoveSpriteOutOfTile
  procedure MoveSpriteOutOfTile(m: Map; s: Sprite; x, y: LongInt);

  /// @lib
  /// @class Map
  /// @method MapTagCount
  function MapTagCount(m: Map; tagType: MapTag): LongInt;

  /// @lib
  /// @class Map
  /// @method MapTagPositionX
  function MapTagPositionX(m: Map; tagType: MapTag; tagnumber: LongInt): LongInt;

  /// @lib
  /// @class Map
  /// @method MapTagPositionY
  function MapTagPositionY(m: Map; tagType: MapTag; tagnumber: LongInt): LongInt;

  /// @lib
  /// @class Sprite
  /// @self 2
  /// @method CollisionWithMap
  function CollisionWithMap(m: Map; s: Sprite; const vec: Vector): CollisionSide;
  //TODO: reorder map/sprite - make the sprite first param. vec is what?

  /// @lib
  /// @class Map
  /// @getter Width
  function MapWidth(m: Map): LongInt;

  /// @lib
  /// @class Map
  /// @getter Height
  function MapHeight(m: Map): LongInt;

  /// @lib
  /// @class Map
  /// @getter BlockWidth
  function BlockWidth(m: Map): LongInt;

  /// @lib
  /// @class Map
  /// @getter BlockHeight
  function BlockHeight(m: Map): LongInt;

  // TODO: Do Gap/Stagger need to be public? Concept need to be documented?
  // GapX and GapY = The distance between each tile (rectangular), can be
  // different to the normal width and height of the block
  //  StaggerX and StaggerY = The isometric Offset

  /// The x distance between each tile. See StaggerX for the isometric offset.
  /// @lib
  /// @class Map
  /// @getter GapX
  function GapX(m: Map): LongInt;

  /// The y distance between each tile. See StaggerY for the isometric offset.
  /// @lib
  /// @class Map
  /// @getter GapY
  function GapY(m: Map): LongInt;

  /// The isometric x offset value.
  /// @lib
  /// @class Map
  /// @getter StaggerX
  function StaggerX(m: Map): LongInt;

  /// The isometric y offset value.
  /// @lib
  /// @class Map
  /// @getter StaggerY
  function StaggerY(m: Map): LongInt;


  /// Return the tile that is under a given Point2D. Isometric maps are taken
  /// into consideration.  A MapTile knows its x,y index in the map structure,
  /// the top-right corner of the tile and the 4 points that construct the tile.
  /// For Isometric tiles, the 4 points will form a diamond.
  /// @lib
  /// @class Map
  /// @self 2
  /// @method GetTileFromPoint
  function GetTileFromPoint(const point: Point2D; m: Map): MapTile;
  //TODO: Why is the map the second parameter? Inconsistent...

  /// Returns the MapTag of the tile at the given (x,y) map index.
  /// Note that if the tile does not have an tag, will return MapTag(-1)
  /// @lib
  /// @class Map
  /// @method GetTagAtTile
  function GetTagAtTile(m: Map; xIndex, yIndex: LongInt): MapTag;


//=============================================================================
implementation
//=============================================================================

  uses
    SysUtils, Classes,  //System,
    sgGraphics, sgCamera, sgCore, sgPhysics, sgGeometry, sgResources, sgSprites, sgShared; //Swingame

  procedure DrawMap(m: Map);
  var
    l, y ,x: LongInt;
    XStart, YStart, XEnd, YEnd: LongInt;
    f: LongInt;
  begin
    if m = nil then begin RaiseException('No Map supplied (nil)'); exit; end;

    //WriteLn('GX, GY: ', ToWorldX(0), ',' , ToWorldY(0));
    //WriteLn('bw, bh: ', m^.MapInfo.BlockWidth, ', ', m^.MapInfo.BlockHeight);

    //TODO: Optimize - the x/yStart (no need to keep re-calculating)
    //Screen Drawing Starting Point
    XStart := round((ToWorldX(0) / m^.MapInfo.BlockWidth) - (m^.MapInfo.BlockWidth * 1));
    YStart := round((ToWorldY(0) / m^.MapInfo.BlockHeight) - (m^.MapInfo.BlockHeight * 1));

    //Screen Drawing Ending point
    XEnd := round(XStart + (sgCore.ScreenWidth() / m^.MapInfo.BlockWidth) + (m^.MapInfo.BlockWidth * 1));
    YEnd := round(YStart + (sgCore.ScreenHeight() / m^.MapInfo.BlockHeight) + (m^.MapInfo.BlockHeight * 1));


    //WriteLn('DrawMap ', XStart, ',', YStart, ' - ',  XEnd, ',', YEnd);

    if YStart < 0 then YStart := 0;
    if YStart >= m^.MapInfo.MapHeight then exit;
    if YEnd < 0 then exit;
    if YEnd >= m^.MapInfo.MapHeight then YEnd := m^.MapInfo.MapHeight - 1;

    if XStart < 0 then XStart := 0;
    if XStart >= m^.MapInfo.MapWidth then exit;
    if XEnd < 0 then exit;
    if XEnd >= m^.MapInfo.MapWidth then XEnd := m^.MapInfo.MapWidth - 1;

    for y := YStart  to YEnd do
    begin
      //TODO: Optimize - no need to re-test "isometric" - separate and do it ONCE!

      //Isometric Offset for Y
      if m^.MapInfo.Isometric then
        m^.Tiles^.position.y := y * m^.MapInfo.StaggerY
      else
        m^.Tiles^.position.y := y * m^.MapInfo.BlockHeight;

      for x := XStart to XEnd do
      begin
        //Isometric Offset for X
        if (m^.MapInfo.Isometric = true) then
        begin
          m^.Tiles^.position.x := x * m^.MapInfo.GapX;
          if ((y MOD 2) = 1) then
            m^.Tiles^.position.x := m^.Tiles^.position.x + m^.MapInfo.StaggerX;
        end
        else
          m^.Tiles^.position.x := x * m^.MapInfo.BlockWidth;

        for l := 0 to m^.MapInfo.NumberOfLayers - m^.MapInfo.CollisionLayer - m^.MapInfo.TagLayer - 1 do
        begin
          if (m^.LayerInfo[l].Animation[y][x] = 0) and (m^.LayerInfo[l].Value[y][x] > 0) then
          begin
            m^.Tiles^.currentCell := m^.LayerInfo[l].Value[y][x] - 1;
            //DrawSprite(m^.Tiles, CameraX, CameraY, sgCore.ScreenWidth(), sgCore.ScreenHeight());
            DrawSprite(m^.Tiles);
          end
          else if (m^.LayerInfo[l].Animation[y][x] = 1) then
          begin
            f := round(m^.Frame/10) mod (m^.AnimationInfo[m^.LayerInfo[l].Value[y][x]].NumberOfFrames);
            m^.Tiles^.currentCell := m^.AnimationInfo[m^.LayerInfo[l].Value[y][x]].Frame[f] - 1;
            DrawSprite(m^.Tiles);
          end;
        end;
      end;
    end;

    m^.Frame := (m^.Frame + 1) mod 1000;
  end;

  //Gets the number of MapTag of the specified type
  function MapTagCount(m: Map; tagType: MapTag): LongInt;
  begin
    if m = nil then begin RaiseException('No Map supplied (nil)'); exit; end;
    if (tagType < MapTag1) or (tagType > High(MapTag)) then begin RaiseException('TagType is out of range'); exit; end;
    
    result := Length(m^.TagInfo[LongInt(tagType)]);
    //TODO: WHY do we keep converting tagType to LongInt - just store as LongINT!!!
    
    {count := 0;
  
    for y := 0 to m^.MapInfo.MapWidth - 1 do
    begin
      for x := 0 to m^.MapInfo.MapHeight - 1 do
      begin
        if tag = m^.TagInfo.Tag[y][x] then
          count := count + 1;
      end;
    end;
    result := count;}
  end;

  // Gets the Top Left X Coordinate of the MapTag
  function MapTagPositionX(m: Map; tagType: MapTag; tagnumber: LongInt): LongInt;
  begin
    if (tagnumber < 0) or (tagnumber > MapTagCount(m, tagType) - 1) then begin RaiseException('Tag number is out of range'); exit; end;

    if (m^.MapInfo.Isometric = true) then
    begin
      result := m^.TagInfo[LongInt(tagType)][tagnumber].x * m^.MapInfo.GapX;
      if ((m^.TagInfo[LongInt(tagType)][tagnumber].y MOD 2) = 1) then
        result := result + m^.MapInfo.StaggerX;
      end
    
    else
      result := m^.TagInfo[LongInt(tagType)][tagnumber].x * m^.MapInfo.BlockWidth;
  
  end;

  // Gets the Top Left Y Coordinate of the MapTag
  function MapTagPositionY(m: Map; tagType: MapTag; tagnumber: LongInt): LongInt;
  begin
    if (tagnumber < 0) or (tagnumber > MapTagCount(m, tagType) - 1) then begin RaiseException('Tag number is out of range'); exit; end;
  
    if (m^.MapInfo.Isometric = true) then
    begin
      result := m^.TagInfo[LongInt(tagType)][tagnumber].y * m^.MapInfo.StaggerY;
    end
    else      
    begin
      result := m^.TagInfo[LongInt(tagType)][tagnumber].y * m^.MapInfo.BlockHeight;
    end;
  end;

  function BruteForceDetection(m: Map; s: Sprite): Boolean;
  const
    SEARCH_RANGE = 0;
  var
    XStart, XEnd, YStart, YEnd: LongInt;
    y, x, yCache: LongInt;
  begin
    result := false;

    with m^.MapInfo do begin
      XStart := round((s^.position.x / BlockWidth) - ((s^.width / BlockWidth) - SEARCH_RANGE));
      XEnd := round((s^.position.x / BlockWidth) + ((s^.width / BlockWidth) + SEARCH_RANGE));
      YStart := round((s^.position.y / BlockHeight) - ((s^.height / BlockHeight) - SEARCH_RANGE));
      YEnd := round((s^.position.y / BlockHeight) + ((s^.height / BlockHeight) + SEARCH_RANGE));

      if YStart < 0 then YStart := 0;
      if YStart >= MapHeight then exit;
      if YEnd < 0 then exit;
      if YEnd >= MapHeight then YEnd := MapHeight - 1;

      if XStart < 0 then XStart := 0;
      if XStart >= MapWidth then exit;
      if XEnd < 0 then exit;
      if XEnd >= MapWidth then XEnd := MapWidth - 1;

      for y := YStart to YEnd do
      begin
        yCache := y * BlockHeight;

        for x := XStart to XEnd do
          if m^.CollisionInfo.Collidable[y][x] then
            if SpriteRectCollision(s, x * BlockWidth, yCache, BlockWidth, BlockHeight) then
            begin
              result := true;
              exit;
            end;
      end;
    end; // with
  end;

  function BruteForceDetectionComponent(m: Map; var s: Sprite; xOffset, yOffset: LongInt): Boolean;
  begin
    s^.position.x := s^.position.x + xOffset;
    s^.position.y := s^.position.y + yOffset;

    result := BruteForceDetection(m, s);
{    if BruteForceDetection(m, s) then
    begin
      result := true;
    end
    else
      result := false;}

    s^.position.x := s^.position.x - xOffset;
    s^.position.y := s^.position.y - yOffset;
  end;

  procedure MoveOut(s: Sprite; velocity: Vector; x, y, width, height: LongInt);
  var
    kickVector: Vector;
    sprRect, tgtRect: Rectangle;
  begin
    sprRect := RectangleFrom(s);
    tgtRect := RectangleFrom(x, y, width, height);
    kickVector := VectorOutOfRectFromRect(sprRect, tgtRect, velocity);
    MoveSprite(s, kickVector);
  end;

  function GetPotentialCollisions(m: Map; s: Sprite): Rectangle;
    function GetBoundingRectangle(): Rectangle;
    var
      startPoint, endPoint: Rectangle;
      startX, startY, endX, endY: LongInt;
    begin
      with m^.MapInfo do begin
        startPoint := RectangleFrom(
          round( ((s^.position.x - s^.velocity.x) / BlockWidth) - 1) * BlockWidth,
          round( ((s^.position.y - s^.velocity.y) / BlockHeight) - 1) * BlockHeight,
          (round( s^.width / BlockWidth) + 2) * BlockWidth,
          (round( s^.height / BlockHeight) + 2) * BlockHeight
        );
        endPoint := RectangleFrom(
          round(((s^.position.x + s^.width) / BlockWidth) - 1) * BlockWidth,
          round(((s^.position.y + s^.height) / BlockHeight) - 1) * BlockHeight,
          (round(s^.width / BlockWidth) + 2) * BlockWidth,
          (round(s^.height / BlockHeight) + 2) * BlockHeight
        );
      end; // with

      //Encompassing Rectangle
      if startPoint.x < endPoint.x then
      begin
        startX := round(startPoint.x);
        endX := round(endPoint.x + endPoint.width);
      end
      else
      begin
        startX := round(endPoint.x);
        endX := round(startPoint.x + startPoint.width);
      end;

      if startPoint.y < endPoint.y then
      begin
        startY := round(startPoint.y);
        endY := round(endPoint.y + endPoint.height);
      end
      else
      begin
        startY := round(endPoint.y);
        endY := round(startPoint.y + startPoint.height);
      end;

      result := RectangleFrom(startX, startY, endX - startX, endY - startY);

      //Debug Info
      //DrawRectangle(ColorYellow, startPoint.x, startPoint.y, startPoint.width, startPoint.height);
      //DrawRectangle(ColorWhite, endPoint.x, endPoint.y, endPoint.width, endPoint.height);
      //DrawRectangle(ColorGreen, result.x, result.y, result.width, result.height);
    end;
  begin
    //Respresents the Rectangle that encompases both the Current and Previous positions of the Sprite.
    //Gets the Bounding Collision Rectangle
    result := GetBoundingRectangle();
    //TODO: Why is this an inner function with it does ALL the work??
  end;

  function WillCollideOnSide(m: Map; s: Sprite): CollisionSide;
  type
    Collisions = record
      Top, Bottom, Left, Right: Boolean;
    end;
  var
    col: Collisions;
  begin
    col.Right  := (s^.velocity.x > 0) and BruteForceDetectionComponent(m, s, s^.width, 0);
    col.Left   := (s^.velocity.x < 0) and BruteForceDetectionComponent(m, s, -s^.width, 0);
    col.Top    := (s^.velocity.y < 0) and BruteForceDetectionComponent(m, s, 0, -s^.height);
    col.Bottom := (s^.velocity.y > 0) and BruteForceDetectionComponent(m, s, 0, s^.height);

    if col.Right and col.Bottom then result := BottomRight
    else if col.Left and col.Bottom then result := BottomLeft
    else if col.Right and col.Top then result := TopRight
    else if col.Left and col.Top then result := TopLeft
    else if col.Left then result := Left
    else if col.Right then result := Right
    else if col.Top then result := Top
    else if col.Bottom then result := Bottom
    else result := None;
  end;

  procedure MoveSpriteOutOfTile(m: Map; s: Sprite; x, y: LongInt);
  begin
    //TODO: Avoid these exception tests (at least the first 2) - do them earlier during loading
    if m = nil then begin RaiseException('No Map supplied (nil)'); exit; end;
    if s = nil then begin RaiseException('No Sprite suppled (nil)'); exit; end;
    if (x < 0 ) or (x >= m^.mapInfo.mapWidth) then begin RaiseException('x is outside the bounds of the map'); exit; end;
    if (y < 0 ) or (y >= m^.mapInfo.mapWidth) then begin RaiseException('y is outside the bounds of the map'); exit; end;
    with m^.MapInfo do
      MoveOut(s, s^.velocity, x * BlockWidth, y * BlockHeight, BlockWidth, BlockHeight);
  end;


  function SpriteHasCollidedWithTile(m: Map; s: Sprite): Boolean; overload;
  var
    x, y: LongInt;
  begin
    result := SpriteHasCollidedWithTile(m, s, x, y);
  end;

  function SpriteHasCollidedWithTile(m: Map; s: Sprite; out collidedX, collidedY: LongInt): Boolean; overload;
  var
    y, x, yCache, dy, dx, i, j, initY, initX: LongInt;
    xStart, yStart, xEnd, yEnd: LongInt;
    rectSearch: Rectangle;
    side: CollisionSide;
  begin
    result := false;
    if m = nil then begin RaiseException('No Map supplied (nil)'); exit; end;
    if s = nil then begin RaiseException('No Sprite suppled (nil)'); exit; end;

    rectSearch := GetPotentialCollisions(m, s);
    side := GetSideForCollisionTest(s^.velocity);
    with m^.MapInfo do begin
      yStart := round(rectSearch.y / BlockHeight);
      yEnd := round((rectSearch.y + rectSearch.height) / BlockHeight);
      xStart := round(rectSearch.x / BlockWidth);
      xEnd := round((rectSearch.x + rectSearch.width) / BlockWidth);

      if yStart < 0 then yStart := 0;
      if yStart >= MapHeight then exit;
      if yEnd < 0 then exit;
      if yEnd >= MapHeight then yEnd := MapHeight - 1;

      if xStart < 0 then xStart := 0;
      if xStart >= MapWidth then exit;
      if xEnd < 0 then exit;
      if xEnd >= MapWidth then xEnd := MapWidth - 1;
     end; //with
//    result := false;

    case side of
      TopLeft: begin dy := 1; dx := 1; initY := yStart; initX := xStart; end;
      TopRight: begin dy := 1; dx := -1; initY := yStart; initX := xEnd; end;
      BottomLeft: begin dy := -1; dx := 1; initY := yEnd; initX := xStart; end;
      BottomRight: begin dy := -1; dx := -1; initY := yEnd; initX := xEnd; end;
      Top: begin dy := 1; dx := 1; initY := yStart; initX := xStart; end;
      Bottom: begin dy := -1; dx := 1; initY := yEnd; initX := xStart; end;
      Left: begin dy := 1; dx := 1; initY := yStart; initX := xStart; end;
      Right: begin dy := 1; dx := -1; initY := yStart; initX := xEnd; end;
      else
      begin dy := 1; dx := 1; initY := yStart; initX := xStart; end;
    end;

    with m^.MapInfo do begin
      for i := yStart to yEnd do
      begin
        y := initY + (i - yStart) * dy;
        yCache := y * BlockHeight;
        for j := xStart to xEnd do
        begin
          x := initX + (j - xStart) * dx; //TODO: Optimize - j start at 0 instead...
          if m^.CollisionInfo.Collidable[y][x] = true then
          begin
            if SpriteRectCollision(s, x * BlockWidth, yCache, BlockWidth, BlockHeight) then
            begin
              result := true;
              collidedX := x;
              collidedY := y;
              exit;
            end;
          end;
        end;
      end;
    end; // with

    collidedX := -1;
    collidedY := -1;

  end;

  function CollisionWithMap(m: Map; s: Sprite; const vec: Vector): CollisionSide;
  var
    x, y: LongInt;
    temp: Vector;
  begin
    result := None;
    temp := s^.velocity;
    s^.velocity := vec;
    if sgTileMap.SpriteHasCollidedWithTile(m, s, x, y) then
    begin
      MoveSpriteOutOfTile(m, s, x, y);
      result := WillCollideOnSide(m, s);
    end;
    s^.velocity := temp;
  end;

  function MapWidth(m: Map): LongInt;
  begin
    result := m^.MapInfo.MapWidth;
  end;

  function MapHeight(m: Map): LongInt;
  begin
    result := m^.MapInfo.MapHeight;
  end;

  function BlockWidth(m: Map): LongInt;
  begin
    result := m^.MapInfo.BlockWidth;
  end;

  function BlockHeight(m: Map): LongInt;
  begin
    result := m^.MapInfo.BlockHeight;
  end;

  function GapX(m: Map): LongInt;
  begin
    result := m^.MapInfo.GapX;
  end;

  function GapY(m: Map): LongInt;
  begin
    result := m^.MapInfo.GapY;
  end;

  function StaggerX(m: Map): LongInt;
  begin
    result := m^.MapInfo.StaggerX;
  end;

  function StaggerY(m: Map): LongInt;
  begin
    result := m^.MapInfo.StaggerY;
  end;

  //Determines whether the specified point is within the tile provided
  function IsPointInTile(point: Point2D; x, y: LongInt; m: Map): Boolean;
  var
    tri: Triangle;
  begin
    with m^.MapInfo do begin
      if Isometric then
      begin
        // Create Triangle
        tri := TriangleFrom(x, y + BlockHeight / 2,
                            x + BlockWidth / 2, y,
                            x + BlockWidth / 2, y + BlockHeight);
        // Test first triangle and leave early?
        if PointInTriangle(point, tri) then
        begin
          result := True;
          exit;
        end
        // Need to test the second triangle too...
        else
        begin
          tri := TriangleFrom(x + BlockWidth, y + BlockHeight / 2,
                              x + BlockWidth / 2, y,
                              x + BlockWidth / 2, y + BlockHeight);
          // store result and done
          result := PointInTriangle(point, tri);
        end;
      end
      else
        result := PointInRect(point, x, y, BlockWidth, BlockHeight);
    end;
  end;


  function GetTileFromPoint(const point: Point2D; m: Map): MapTile;
  var
    x, y, tx, ty: LongInt;
  begin
    //Returns (-1,-1) if no tile has this point
    result.xIndex := -1;
    result.yIndex := -1;
    result.topCorner := PointAt(0,0);
    result.PointA := PointAt(0,0);
    result.PointB := PointAt(0,0);
    result.PointC := PointAt(0,0);
    result.PointD := PointAt(0,0);

    with m^.MapInfo do begin
      if Isometric then
        for y := 0 to MapHeight - 1 do
        begin
          // tile y pos?
          ty := y * StaggerY;
          for x := 0  to MapWidth - 1  do
          begin
            // tile x pos?
            tx := x * GapX;
            if ((y MOD 2) = 1) then tx := tx + StaggerX;
            // test and leave?
            if IsPointInTile(point, tx, ty, m) then
            begin
              result.xIndex := x;
              result.yIndex := y;
              result.topCorner := PointAt(tx,ty);
              result.PointA := PointAt(tx, ty + BlockHeight / 2);
              result.PointB := PointAt(tx + BlockWidth / 2, ty);
              result.PointC := PointAt(tx + BlockWidth / 2, ty + BlockHeight);
              result.PointD := PointAt(tx + BlockWidth, ty + BlockHeight / 2);
              exit;
            end;
          end;
        end
      else // Simple square-map (not isometric diamonds)
        for y := 0 to MapHeight - 1 do
        begin
          ty := y * BlockHeight;
          for x := 0  to MapWidth - 1  do
          begin
            tx := x * BlockWidth;
            if IsPointInTile(point, tx, ty, m) then
            begin
              result.xIndex := x;
              result.yIndex := y;
              result.topCorner := PointAt(tx,ty);
              //TODO: Optimize - recalc of PointsA/B/C/D - store and keep.
              result.PointA := PointAt(tx, ty);
              result.PointB := PointAt(tx + BlockWidth, ty);
              result.PointC := PointAt(tx, ty + BlockHeight);
              result.PointD := PointAt(tx + BlockWidth, ty + BlockHeight);
              exit;
            end;
          end;
        end;

{ // Old code - shorter, but takes longer
      for y := 0 to MapHeight - 1 do
      begin
        //TODO: Optimize - to isometric test ONCE not multiple times...
        //Isometric Offset for Y
        if Isometric then
          ty := y * StaggerY
        else
          ty := y * BlockHeight;

        for x := 0  to MapWidth - 1  do
        begin

          //Isometric Offset for X
          if Isometric then
          begin
            tx := x * GapX;
            if ((y MOD 2) = 1) then
              tx := tx + StaggerX;
          end
          else
            tx := x * BlockWidth;

          if IsPointInTile(point, tx, ty, m) then
          begin
            result.xIndex := x;
            result.yIndex := y;
            result.topCorner := PointAt(tx,ty);
            if Isometric then
            begin
              result.PointA := PointAt(tx, ty + BlockHeight / 2);
              result.PointB := PointAt(tx + BlockWidth / 2, ty);
              result.PointC := PointAt(tx + BlockWidth / 2, ty + BlockHeight);
              result.PointD := PointAt(tx + BlockWidth, ty + BlockHeight / 2);
              exit;
            end
            else
            begin
              result.PointA := PointAt(tx, ty);
              result.PointB := PointAt(tx + BlockWidth, ty);
              result.PointC := PointAt(tx, ty + BlockHeight);
              result.PointD := PointAt(tx + BlockWidth, ty + BlockHeight);
              exit; // ARGH!
            end;
          end;
        end;
      end;
}
    end; // with
  end;

  function GetTagAtTile(m: Map; xIndex, yIndex: LongInt): MapTag;
  var
    i, j: LongInt;
  begin
    for i := LongInt(Low(MapTag)) to LongInt(High(MapTag)) do
      if (Length(m^.TagInfo[i]) > 0) then
        for j := 0 to High(m^.TagInfo[i]) do
          if (m^.TagInfo[i][j].x = xIndex) and (m^.TagInfo[i][j].y = yIndex) then
          begin
            result := MapTag(i);
            exit;
          end;
    // default result
    result := MapTag(-1);
  end;
  
  
//=============================================================================

  initialization
  begin
    InitialiseSwinGame();
  end;

end.