{
    SwinGame Asteroids
    Copyright (C) 2013  SpiltCoffee

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}

unit asOffscreen;

interface
  uses sgTypes, asTypes;

  function ProximityCheck(fromPoint, toPoint: Point2D; const dist: Double): Boolean;

  function CheckIfSpaceEmpty(const position: Point2D; const radius: Double; const asteroids: TAsteroidArray; const enemy: TShip): Boolean; overload;
  function CheckIfSpaceEmpty(const asteroids: TAsteroidArray; const cur: Integer): Boolean; overload;

  function CalculateDistWithWrap(fromPoint, toPoint: Point2D): Double;

  function CalculateAngleWithWrap(fromPoint, toPoint: Point2D): Double;

  procedure WrapPosition(var pos: Point2D);

  function OffscreenPosition(const objectRadius: Integer): Point2D;

  function OffscreenSide(const pos: Point2D; out side: Integer): Point2D;

implementation
  uses sgCore, sgGeometry, asConstants;

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

  function CheckIfSpaceEmpty(const position: Point2D; const radius: Double; const asteroids: TAsteroidArray; const enemy: TShip): Boolean; overload;
  var
    i: Integer;
  begin
    result := True;
    if not ProximityCheck(enemy.pos, position, enemy.rad + radius) then begin
      result := False;
    end
    else begin
      for i := Low(asteroids) to High(asteroids) do begin
        if not ProximityCheck(asteroids[i].pos, position, asteroids[i].rad + radius) then begin
          result := False;
          break;
        end;
      end;
    end;
  end;

  function CheckIfSpaceEmpty(const asteroids: TAsteroidArray; const cur: Integer): Boolean; overload;
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

end.
