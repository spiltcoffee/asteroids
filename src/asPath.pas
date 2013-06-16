unit asPath;

interface
  uses asTypes, sgTypes, asStackQueue;

type
  TDistArray = array of array of Integer;

// - method that creates a random path
  function CreateRandomPath(const res: Size; const looped: Boolean): TPath;
  function CreateEmptyPath: TPath;

// - method that takes a map, a starting cell, an ending cell, and provides a path that avoids asteroids
  function FindPath(const map: TMap; const start_pos: Point2D; const end_pos: Point2D): TPath;

  function FindSmallest(var next: TLinkedList; const distance: TDistArray): Point2D;

// - method that returns the current point to seek on the path
  function CurrentPoint(const path: TPath): Point2D;

// - method that takes a path and a map, and checks if the path is 'valid' i.e. it does not touch any asteroids
  function PathStillValid(const path: TPath; const map: TMap): Boolean;
  function PathStillRelevant(const path: TPath; const target: Point2D): Boolean;

  function PathFinished(const path: TPath): Boolean;

  function PathEnd(const path: TPath): Point2D;

// - method that updates which point on the path to move towards
  procedure UpdatePath(var path: TPath; const ship_pos: Point2D);

// - method that draws a path
  procedure DrawPath(const ship: TShip);

implementation
  uses Math, sgGeometry, sgGraphics, asInfluenceMap, sysutils, asConstants;

// - method that creates a random path
  function CreateRandomPath(const res: Size; const looped: Boolean): TPath;
  var
    i: Integer;
  begin
    SetLength(result.points, random(7) + 3);
    for i := Low(result.points) to High(result.points) do begin
      result.points[i].x := random(res.width);
      result.points[i].y := random(res.height);
    end;
    result.current := 0;
    result.looped := looped;
  end;

  function CreateEmptyPath: TPath;
  begin
    SetLength(result.points, 0);
    result.current := 0;
    result.looped := False;
  end;

// returns a TPathFindEnum pointing to source from neighbour
  function ReverseLookupNeighbour(const neighbour_pos: Point2D; const source_pos: Point2D): TPathFindEnum;
  var
    lookup: Point2D;
    item: TPathFindEnum;
  begin
    result := pfNone;

    lookup := neighbour_pos - source_pos;
    for item in [Low(TPathFindEnum)..High(TPathFindEnum)] do begin
      if (C_PathFindPoint[item].x = trunc(lookup.x)) and (C_PathFindPoint[item].y = trunc(lookup.y)) then begin
        result := item
      end;
    end;
  end;

// - method that takes a map, a starting cell, an ending cell, and provides a path that avoids asteroids
  function FindPath(const map: TMap; const start_pos: Point2D; const end_pos: Point2D): TPath;
  var
    distance: TDistArray;
    previous: array of array of TPathFindEnum;
    next: TLinkedList;
    final_path: TLinkedList;
    i, j: Integer;

    current: Point2D;
    current_distance: Integer;
    neighbour: Point2D;

    item: TPathFindEnum;
    last_item: TPathFindEnum;
    map_start_pos: Point2D;
    map_end_pos: Point2D;
  begin
    //WriteLn('FindPath begin ');
    map_start_pos := MapPosition(start_pos);
    map_end_pos := MapPosition(end_pos);

    SetupList(next);
    SetupList(final_path);

    SetLength(distance, Length(map), Length(map[0]));
    SetLength(previous, Length(map), Length(map[0]));

    for i := Low(map) to High(map) do begin
      for j := Low(map[0]) to High(map[0]) do begin
        distance[i, j] := 10000;
        previous[i, j] := pfNone;
      end;
    end;

    distance[trunc(map_start_pos.x), trunc(map_start_pos.y)] := 0;
    Enqueue(next, map_start_pos);

    //WriteLn('Start Loop');
    repeat
      //WriteLn('Current Queue Length: ', CountNodes(next));
      current := FindSmallest(next, distance);
      current_distance := distance[trunc(current.x), trunc(current.y)] + map[trunc(current.x), trunc(current.y)];
      //WriteLn('Current Distance: ', current_distance);
      //WriteLn('current.x = ', current.x, ', current.y = ', current.y);

      for item in [pfUp, pfRight, pfDown, pfLeft] do begin
        neighbour := current + C_PathFindPoint[item];

        if (neighbour.x >= 0) and (neighbour.x <= High(distance)) and
          (neighbour.y >= 0) and (neighbour.y <= High(distance[0])) then begin

          if (distance[trunc(neighbour.x), trunc(neighbour.y)] > current_distance) then begin
            distance[trunc(neighbour.x), trunc(neighbour.y)] := current_distance;
            previous[trunc(neighbour.x), trunc(neighbour.y)] := C_PathFindOpposite[item];

            AppendUniqueNode(next, neighbour);
            //Enqueue(next, neighbour);
          end;

        end;

      end;

    until ((current.x = map_end_pos.x) and (current.y = map_end_pos.y)) or (CountNodes(next) = 0);
    //WriteLn('Finish Loop');

    if (current.x = map_end_pos.x) and (current.y = map_end_pos.y) then begin
      Push(final_path, current);
      last_item := pfNone;
      item := previous[trunc(current.x), trunc(current.y)];
      while item <> pfNone do begin
        current := current + C_PathFindPoint[previous[trunc(current.x), trunc(current.y)]];
        item := previous[trunc(current.x), trunc(current.y)];
        if item <> last_item then begin
          Push(final_path, current);
          last_item := item;
        end;
      end;

      SetLength(result.points, CountNodes(final_path));

      for i := 0 to CountNodes(final_path) - 1 do begin
        result.points[i] := RealPosition(Pop(final_path));
      end;

      result.current := 0;
      result.looped := False;
    end
    else begin
      SetLength(result.points, 0);
      result.current := 0;
      result.looped := False;
    end;

    DestroyList(next);
    DestroyList(final_path);

    SetLength(distance, 0, 0);
    SetLength(previous, 0, 0);
    //WriteLn('FindPath end');
  end;

  function FindSmallest(var next: TLinkedList; const distance: TDistArray): Point2D;
  var
    i: Integer;
    current: Point2D;
    smallest_pos: Integer;
    smallest_dist: Integer;
  begin
    smallest_pos := -1;
    smallest_dist := 0;
    for i := 0 to CountNodes(next)-1 do begin
      current := GetNodeValue(next, i);
      if (smallest_pos = -1) or (distance[trunc(current.x), trunc(current.y)] < smallest_dist) then begin
        smallest_pos := i;
        smallest_dist := distance[trunc(current.x), trunc(current.y)];
      end;
    end;

    if smallest_pos >= 0 then begin
      result := SpliceNode(next, smallest_pos);
    end
    else begin
      WriteLn('No Node removed! Huh?!');
    end;
  end;

// - method that returns the current point to seek on the path
  function CurrentPoint(const path: TPath): Point2D;
  begin
    if Length(path.points) > 0 then begin
      result := path.points[path.current];
    end
    else begin
      result.x := 0;
      result.y := 0;
    end;
  end;

// - method that takes a path and a map, and checks if the path is 'valid' i.e. it does not touch any asteroids
  function PathStillValid(const path: TPath; const map: TMap): Boolean;
  var
    point: Point2D;
  begin
    result := True;

    if (Length(path.points) > 0) then begin
      if (path.current <> High(path.points)) then begin
        point := MapPosition(path.points[path.current]);
        if map[trunc(point.x), trunc(point.y)] > 300 then begin
          result := False;
        end;
      end;
    end
    else begin
      result := False;
    end;

  end;

  function PathStillRelevant(const path: TPath; const target: Point2D): Boolean;
  var
    last_point: Point2D;
  begin
    result := True;

    if Length(path.points) > 0 then begin
      last_point := path.points[Length(path.points)];
      if PointPointDistance(last_point, target) > 100 then begin
        result := False;
      end;
    end;
  end;

  function PathFinished(const path: TPath): Boolean;
  begin
    result := not path.looped and ((path.current = High(path.points)) or (Length(path.points) = 0));
  end;

  function PathEnd(const path: TPath): Point2D;
  begin
    if Length(path.points) > 0 then begin
      result := path.points[High(path.points)];
    end
    else begin
      result.x := 0;
      result.y := 0;
    end;
  end;

// - method that updates which point on the path to move towards
  procedure UpdatePath(var path: TPath; const ship_pos: Point2D);
  var
    current_point: Point2D;
    next_point: Point2D;
  begin
    if Length(path.points) > 0 then begin
      current_point := path.points[path.current];

      if path.current = High(path.points) then begin
        next_point := path.points[0];
      end
      else begin
        next_point := path.points[path.current + 1];
      end;

      if (PointPointDistance(path.points[path.current], ship_pos) < PATH_DIST_NEXT) or
        (PointPointDistance(current_point, ship_pos) > PointPointDistance(next_point, ship_pos)) then
      begin

        if (path.current < High(path.points)) then begin
          path.current += 1;
        end
        else if path.looped then begin
          path.current := 0;
        end;

      end;

    end;

  end;

// - method that draws a path
  procedure DrawPath(const ship: TShip);
  var
    i: Integer;
    path: TPath;
    offset: Point2D;
  begin
    path := ship.path;
    offset.x := 0;
    offset.y := 0;
    if ship.kind = sk2ShipAI then begin
      offset.x := 1;
      offset.y := 1;
    end;
    for i := Low(path.points) to High(path.points) - 1 do begin
      DrawLine(ship.color, path.points[i] + offset, path.points[i + 1] + offset);
    end;
    if path.looped then begin
      DrawLine(ship.color, path.points[High(path.points)] + offset, path.points[0] + offset);
    end;
    if Length(path.points) > 0 then begin
      DrawCircle(ship.color, path.points[path.current], PATH_DIST_NEXT);
    end;
  end;

end.
