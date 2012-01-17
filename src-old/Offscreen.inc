//
//Procedures and functions for screen wrapping
//

function ProximityCheck(fromPoint, toPoint: Point2D; const dist: Double): Boolean;
begin
  result := true;

  if PointPointDistance(fromPoint,toPoint) < dist then
    result := false;

  if (fromPoint.x > toPoint.x) then
    toPoint.x += (ScreenWidth() + BUFFER * 2)
  else if (fromPoint.x < toPoint.x) then
    fromPoint.x += (ScreenWidth() + BUFFER * 2);

  if PointPointDistance(fromPoint,toPoint) < dist then
    result := false;

  if (fromPoint.y > toPoint.y) then
    toPoint.y += (ScreenHeight() + BUFFER * 2)
  else if (fromPoint.y < toPoint.y) then
    fromPoint.y += (ScreenHeight() + BUFFER * 2);

  if PointPointDistance(fromPoint,toPoint) < dist then
    result := false;

  if (fromPoint.x > toPoint.x) then
    fromPoint.x -= (ScreenWidth() + BUFFER * 2)
  else if (fromPoint.x < toPoint.x) then
    toPoint.x -= (ScreenWidth() + BUFFER * 2);

  if PointPointDistance(fromPoint,toPoint) < dist then
    result := false;
end;

function CheckIfSpaceEmpty(const asteroids: TAsteroidArray; const cur: Integer): Boolean;
var
  i: Integer;
begin
  result := true;
  if Length(asteroids) > 1 then
  begin
    for i := 0 to (cur - 1) do
    begin
      if not ProximityCheck(asteroids[i].pos,asteroids[cur].pos,asteroids[i].rad + asteroids[cur].rad) then
      begin
        result := false;
        break;
      end;
    end;
  end;
end;

function CalculateDistWithWrap(fromPoint, toPoint: Point2D): Double;
var
  closestDist: Double;
begin
  closestDist := PointPointDistance(fromPoint,toPoint);
 
  if (fromPoint.x > toPoint.x) then
    toPoint.x += (ScreenWidth() + BUFFER * 2)
  else if (fromPoint.x < toPoint.x) then
    fromPoint.x += (ScreenWidth() + BUFFER * 2);

  if PointPointDistance(fromPoint,toPoint) < closestDist then
    closestDist := PointPointDistance(fromPoint,toPoint);
  
  if (fromPoint.y > toPoint.y) then
    toPoint.y += (ScreenHeight() + BUFFER * 2)
  else if (fromPoint.y < toPoint.y) then
    fromPoint.y += (ScreenHeight() + BUFFER * 2);
  
  if PointPointDistance(fromPoint,toPoint) < closestDist then
    closestDist := PointPointDistance(fromPoint,toPoint);
  
  if (fromPoint.x > toPoint.x) then
    fromPoint.x -= (ScreenWidth() + BUFFER * 2)
  else if (fromPoint.x < toPoint.x) then
    toPoint.x -= (ScreenWidth() + BUFFER * 2);
    
  if PointPointDistance(fromPoint,toPoint) < closestDist then
    closestDist := PointPointDistance(fromPoint,toPoint);
  
  result := closestDist;
end;

function CalculateAngleWithWrap(fromPoint, toPoint: Point2D): Double;
var
  bestAngle, closestDist: Double;
begin
  closestDist := PointPointDistance(fromPoint,toPoint);
  bestAngle := CalculateAngleBetween(fromPoint,toPoint);
 
  if (fromPoint.x > toPoint.x) then
    toPoint.x += (ScreenWidth() + BUFFER * 2)
  else if (fromPoint.x < toPoint.x) then
    fromPoint.x += (ScreenWidth() + BUFFER * 2);

  if PointPointDistance(fromPoint,toPoint) < closestDist then
  begin
    closestDist := PointPointDistance(fromPoint,toPoint);
    bestAngle := CalculateAngleBetween(fromPoint,toPoint);
  end;
  
  if (fromPoint.y > toPoint.y) then
    toPoint.y += (ScreenHeight() + BUFFER * 2)
  else if (fromPoint.y < toPoint.y) then
    fromPoint.y += (ScreenHeight() + BUFFER * 2);
  
  if PointPointDistance(fromPoint,toPoint) < closestDist then
  begin
    closestDist := PointPointDistance(fromPoint,toPoint);
    bestAngle := CalculateAngleBetween(fromPoint,toPoint);
  end;
  
  if (fromPoint.x > toPoint.x) then
    fromPoint.x -= (ScreenWidth() + BUFFER * 2)
  else if (fromPoint.x < toPoint.x) then
    toPoint.x -= (ScreenWidth() + BUFFER * 2);
    
  if PointPointDistance(fromPoint,toPoint) < closestDist then
    bestAngle := CalculateAngleBetween(fromPoint,toPoint);
  
  result := bestAngle;
end;

procedure WrapPosition(var pos: Point2D); //ensures the position is within the defined world area
begin
  if pos.x < -BUFFER then
    pos.x := ScreenWidth() + BUFFER
  else if pos.x > (ScreenWidth() + BUFFER) then
    pos.x := -BUFFER;

  if pos.y < -BUFFER then
    pos.y := ScreenHeight() + BUFFER
  else if pos.y > (ScreenHeight() + BUFFER) then
    pos.y := -BUFFER;
end;

function OffscreenPosition(const objectRadius: Integer): Point2D;
begin
  if (Rnd(2) >= 1) then
  begin
    result.x := Rnd(ScreenWidth());
    result.y := Rnd((BUFFER - objectRadius) * 2) - (BUFFER - objectRadius) - BUFFER;
    if result.y < -BUFFER then
      result.y += ScreenHeight() + BUFFER * 2;
  end
  else
  begin
    result.y := Rnd(ScreenHeight());
    result.x := Rnd((BUFFER - objectRadius) * 2) - (BUFFER - objectRadius) - BUFFER;
    if result.x < -BUFFER then
      result.x += ScreenWidth() + BUFFER * 2;
  end;
end;

// provides the Point2D for the ship pointer for it to position itself correctly
// also provides a number between 1 and 8 relating to which side of the screen we're off for rotation
// (odd numbers are corners, clockwise from the bottom right)

function OffscreenSide(const pos: Point2D; out side: Integer): Point2D;
var
  count: Integer;
begin
  side := 0;
  count := 3;
  result := pos;

  if pos.x > ScreenWidth() then
  begin
    side += 4;
    result.x := ScreenWidth() - PLAYER_INDICATOR_BUFFER;
    count -= 1;
  end;
  if pos.y > ScreenHeight() then
  begin
    side += 1;
    result.y := ScreenHeight() - PLAYER_INDICATOR_BUFFER;
    count -= 1;
  end;

  if side > 4 then
    side := 1;

  if (count > 1) and (pos.x < 0) then
  begin
    side += 2;
    result.x := PLAYER_INDICATOR_BUFFER;
    count -= 1;
  end;
  if (count > 1) and (pos.y < 0) then
  begin
    side += 3;
    result.y := PLAYER_INDICATOR_BUFFER;
    count -= 1;
  end;
  
  side *= count;
end;