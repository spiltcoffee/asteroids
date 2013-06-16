unit asInfluenceMap;

interface
  uses sgTypes, asTypes;

  procedure CreateMap(var map: TMap; const res: Size);

  procedure ResetMap(var map: TMap);

  procedure UpdateMap(var map: TMap; const asteroids: TAsteroidArray);

  procedure DrawMap(const map: TMap; const res: Size);

  function GetInfluenceFromMap(const map: TMap; const pos: Point2D): Integer;

  function MapPosition(const pos: Point2D): Point2D;
  function RealPosition(const pos: point2D): Point2D;

implementation
  uses asConstants, Math, sgGraphics, SysUtils, sgGeometry;

  procedure CreateMap(var map: TMap; const res: Size);
  var
    width, height: Integer;
  begin
    //map must reach into the outside area as well
    //take screen size, add border*2 to width and height, divide by cell size and take the ceiling to get the number of cells width wise and height wise
    width := ceil( (res.width + (BUFFER * 2) ) / MAP_CELL_SIZE);
    height := ceil( (res.height + (BUFFER * 2) ) / MAP_CELL_SIZE);
    //create array of map width and map height
    SetLength(map, width, height);
  end;

  procedure ResetMap(var map: TMap);
  var
    i, j: Integer;
  begin
    //loop all rows
    for i := Low(map) to High(map) do begin
      //loop all cells
      for j := Low(map[0]) to High(map[0]) do begin
        map[i, j] := 0;
      end;
    end;
  end;

  procedure UpdateMap(var map: TMap; const asteroids: TAsteroidArray);
  var
    i: Integer;
    map_pos: Point2D;
    neighbour: Point2D;
    x, y: Integer;
    radius: Integer;
    distance: Double;
    influence: Integer;
  begin

    for i := Low(asteroids) to High(asteroids) do begin

      map_pos := MapPosition(asteroids[i].pos);
      radius := ceil(asteroids[i].rad / MAP_CELL_SIZE) + MAP_FALL_OFF;

      for x := trunc(map_pos.x) - radius to trunc(map_pos.x) + radius do begin
          for y := trunc(map_pos.y) - radius to trunc(map_pos.y) + radius do begin

          neighbour.x := x;
          neighbour.y := y;
          distance := PointPointDistance(map_pos, neighbour);

          if (x >= 0) and (x <= High(map)) and (y >= 0) and (y <= High(map[0])) then begin

            if distance <= (radius - MAP_FALL_OFF) then begin
              map[x, y] += MAP_IMPASS;
            end;
            influence := trunc(MAP_FALL_OFF_MAX - ((MAP_FALL_OFF_MAX/MAP_FALL_OFF) * (distance)));
            map[x, y] += max(influence, 0);

          end;

        end;
      end;

    end;

  end;

  procedure DrawMap(const map: TMap; const res: Size);
  var
    i, j: Integer;
    x, y: Integer;
    color: Integer;
  begin
    //draw lines from the buffer to the other side
    for i := Low(map) to High(map) do begin
      x := -BUFFER + MAP_CELL_SIZE * i;
      DrawLine($1FFFFFFF, x, -BUFFER, x, BUFFER * 2 + res.height);
    //draw squares for each cell that is true
    end;
    for j := Low(map[0]) to High(map[0]) do begin
      y := -BUFFER + MAP_CELL_SIZE * j;
      DrawLine($1FFFFFFF, -BUFFER, y, BUFFER * 2 + res.width, y);
    end;

    for i := Low(map) to High(map) do begin
      for j := Low(map[i]) to High(map[i]) do begin
        if map[i, j] > 0 then begin
          x := -BUFFER + MAP_CELL_SIZE * i;
          y := -BUFFER + MAP_CELL_SIZE * j;
          if map[i, j] > 1000 then begin
            color := $7FFF0000;
          end
          else begin
            color := $01000000 * trunc(map[i, j] / 2000 * 256) + $00FF0000;
          end;
          FillRectangle(color, x, y, MAP_CELL_SIZE, MAP_CELL_SIZE);
        end;
      end;
    end;
  end;

  function GetInfluenceFromMap(const map: TMap; const pos: Point2D): Integer;
  var
    map_pos: Point2D;
  begin
    //translate pos into influence map local x and y
    map_pos := MapPosition(pos);
    result := map[trunc(map_pos.x), trunc(map_pos.y)];
  end;

  function MapPosition(const pos: Point2D): Point2D;
  begin
    result.x := floor(pos.x + BUFFER) div MAP_CELL_SIZE;
    result.y := floor(pos.y + BUFFER) div MAP_CELL_SIZE;
  end;

  function RealPosition(const pos: point2D): Point2D;
  begin
    result.x := (pos.x * MAP_CELL_SIZE) + (MAP_CELL_SIZE/2) - BUFFER;
    result.y := (pos.y * MAP_CELL_SIZE) + (MAP_CELL_SIZE/2) - BUFFER;
  end;

end.
