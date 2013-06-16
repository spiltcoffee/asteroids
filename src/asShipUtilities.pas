unit asShipUtilities;

interface
  uses asTypes, sgTypes;

  function GetActionUtil(action: TShipAction): TActionUtilFunc;
  function GetAction(action: TShipAction): TActionProc;

  function UtilMoveToEnemy(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  procedure ActionMoveToEnemy(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  function UtilEvadeEnemy(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  procedure ActionEvadeEnemy(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  function UtilEvadeAsteroid(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  procedure ActionEvadeAsteroid(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  function UtilShootEnemy(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  procedure ActionShootEnemy(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  function UtilShootAsteroid(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  procedure ActionShootAsteroid(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  //acts as cut off value. If any one of the above is higher than this utility, the above utility is ignored
  function UtilIdle(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  procedure ActionIdle(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

implementation
  uses asShipController, sgGeometry, asOffscreen, asConstants, asPath, sgGraphics, math, asCollisions, sgCore;

  function GetActionUtil(action: TShipAction): TActionUtilFunc;
  begin
    case action of
      saMoveToEnemy: begin
        result := @UtilMoveToEnemy;
      end;
      saEvadeEnemy: begin
        result := @UtilEvadeEnemy;
      end;
      saEvadeAsteroid: begin
        result := @UtilEvadeAsteroid;
      end;
      saShootEnemy: begin
        result := @UtilShootEnemy;
      end;
      saShootAsteroid: begin
        result := @UtilShootAsteroid;
      end;
      saIdle: begin
        result := @UtilIdle;
      end;
    end;
  end;

  function GetAction(action: TShipAction): TActionProc;
  begin
    case action of
      saMoveToEnemy: begin
        result := @ActionMoveToEnemy;
      end;
      saEvadeEnemy: begin
        result := @ActionEvadeEnemy;
      end;
      saEvadeAsteroid: begin
        result := @ActionEvadeAsteroid;
      end;
      saShootEnemy: begin
        result := @ActionShootEnemy;
      end;
      saShootAsteroid: begin
        result := @ActionShootAsteroid;
      end;
      saIdle: begin
        result := @ActionIdle;
      end;
    end;
  end;

  function UtilMoveToEnemy(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  begin
    Result := trunc(PointPointDistance(ship.pos, enemy.pos)) * 3;
    target := CurrentPoint(ship.path);
  end;

  procedure ActionMoveToEnemy(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  begin
    if not (PathStillRelevant(ship.path, enemy.pos) and PathStillValid(ship.path, map)) then begin
      if (ship.controller.pathfind_timeout = 0) then begin
        ship.path := FindPath(map, ship.pos, enemy.pos);
        ship.controller.pathfind_timeout += 30;
      end
      else begin
        ship.controller.pathfind_timeout -= 1;
      end;
    end;

    AIArrive(ship, CurrentPoint(ship.path), rotation, thrust, False);
    shooting := False;
  end;



  function UtilEvadeEnemy(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  var
    bullet_future: Point2D;
    bullet_future_range: Double;
    target_future: Point2D;
    target_future_range: Double;
  begin
    target := enemy.pos;

    bullet_future := enemy.pos + (enemy.vel * BULLET_START);
    bullet_future_range := trunc(BULLET_SPEED * BULLET_START);
    target_future := ship.pos + (ship.vel * BULLET_START);
    target_future_range := PointPointDistance(target_future, bullet_future);
    if target_future_range < (bullet_future_range + AI_EVADE_ENEMY_BUFFER) then begin //in range!
      Result := trunc(target_future_range * 4);
      if enemy.int = 0 then begin
        Result -= trunc(target_future_range); //enemy can shoot, utility more urgent
        if ship.int = 0 then begin
          Result -= trunc(target_future_range); //enemy can shoot, utility more urgent
      end;
      end;
      Result += trunc(target_future_range * AICalcAccuracy(ship.rot, ship.pos, target, False)); //increases if facing enemy, decreases if back to enemy
    end
    else begin
      Result := 100000;
    end;
  end;

  procedure ActionEvadeEnemy(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  begin
    AIEvade(ship, target, rotation, thrust);
    shooting := False;
  end;



  function UtilEvadeAsteroid(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  var
    i: Integer;
    time: Integer;
    time_to_stop: Double;
    dist_to_stop: Double;
    found: Boolean;
    ship_future: Point2D;
    asteroid_future: Point2D;
  begin
    time_to_stop := Max(AITimeToTurn(ship) + AITimeToStop(ship) + AI_EVADE_BUFFER, AI_EVADE_TIME_MIN);
    dist_to_stop := Max(AIDistToStop(ship) + VectorMagnitude(ship.vel) * AI_EVADE_BUFFER, AI_EVADE_DIST_MIN);

    found := False;
    for time := 0 to trunc(time_to_stop/AI_EVADE_STEP) do begin
      for i := Low(asteroids) to High(asteroids) do begin

        if PointPointDistance(ship.pos, asteroids[i].pos) <= dist_to_stop then begin
          ship_future := ship.pos + ship.vel * (time * AI_EVADE_STEP);
          asteroid_future := asteroids[i].pos + asteroids[i].vel * (time * AI_EVADE_STEP);
          if PointPointDistance(ship_future, asteroid_future) < (ship.rad + asteroids[i].rad) then
          begin
            target := FindCollisionPoint(ship_future, ship.rad, asteroid_future, asteroids[i].rad);
            found := True;
            Break;
          end;

        end;
      end;

      if found then begin
        Break;
      end;
    end;

    if found then begin
      Result := trunc(PointPointDistance(ship.pos, target)) * 3;
    end
    else begin
      Result := 100000;
    end;
  end;

  procedure ActionEvadeAsteroid(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  begin
    AIEvade(ship, target, rotation, thrust);
    shooting := False;
  end;



  function UtilShootEnemy(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  var
    bullet_future: Vector;
    bullet_future_range: Integer;
    target_future: Vector;
    time: Integer;
  begin
    Result := 100000;
    if ship.int = 0 then begin
      for time := trunc(BULLET_START/AI_SHOOT_STEP) downto 0 do begin
        bullet_future := ship.pos + (ship.vel * time * AI_SHOOT_STEP);
        bullet_future_range := trunc(BULLET_SPEED * time * AI_SHOOT_STEP);
        target_future := enemy.pos + (enemy.vel * time * AI_SHOOT_STEP);
        if not PointInCircle(target_future, CircleAt(bullet_future, bullet_future_range)) then begin
          Break
        end;
      end;
      time += 1; //loop found the time that the bullet would still be traveling, increment by one to get time of collision assuming it is less than the maximum.
      if time <= trunc(BULLET_START/AI_SHOOT_STEP) then begin
        target := enemy.pos + (enemy.vel * time * AI_SHOOT_STEP);
        result := trunc(PointPointDistance(ship.pos, target) + (-1 * AICalcAccuracy(ship.rot, ship.pos, target, False)) * AI_SHOOT_ACCURACY_FACTOR);
      end;
    end;
  end;

  procedure ActionShootEnemy(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  begin
    AIShoot(ship, target, rotation, thrust, shooting);
  end;



  function UtilShootAsteroid(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  var
    i: Integer;
    time: Integer;
    time_to_stop: Double;
    dist_to_stop: Double;
    found: Boolean;
    ship_future: Point2D;
    asteroid_future: Point2D;
    bullet_future: Vector;
    bullet_future_range: Integer;
    target_future_range: Double;
  begin
    time_to_stop := Max(AITimeToTurn(ship) + AITimeToStop(ship) + AI_EVADE_BUFFER, AI_EVADE_TIME_MIN);
    dist_to_stop := Max(AIDistToStop(ship) + VectorMagnitude(ship.vel) * AI_EVADE_BUFFER, AI_EVADE_DIST_MIN);

    found := False;
    for time := 0 to trunc(time_to_stop/AI_EVADE_STEP) do begin
      for i := Low(asteroids) to High(asteroids) do begin

        if PointPointDistance(ship.pos, asteroids[i].pos) <= dist_to_stop then begin
          ship_future := ship.pos + ship.vel * (time * AI_EVADE_STEP);
          asteroid_future := asteroids[i].pos + asteroids[i].vel * (time * AI_EVADE_STEP);
          if PointPointDistance(ship_future, asteroid_future) < (ship.rad + asteroids[i].rad) then
          begin
            target := FindCollisionPoint(ship_future, ship.rad, asteroid_future, asteroids[i].rad);
            found := True;
            Break;
          end;

        end;
      end;

      if found then begin
        Break;
      end;
    end;

    if found and (time * AI_EVADE_STEP < BULLET_START) then begin
      bullet_future := ship.pos + (ship.vel * time * AI_EVADE_STEP);
      bullet_future_range := trunc(BULLET_SPEED * time * AI_EVADE_STEP);
      target := asteroids[i].pos + asteroids[i].vel * time * AI_EVADE_STEP;
      target_future_range := PointPointDistance(target, bullet_future);
      Result := trunc(target_future_range * 2 + (-1 * AICalcAccuracy(ship.rot, ship.pos, target, False)) * AI_SHOOT_ACCURACY_FACTOR);
    end
    else begin
      Result := 100000;
    end;
  end;

  procedure ActionShootAsteroid(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  begin
    AIShoot(ship, target, rotation, thrust, shooting);
  end;



  //acts as cut off value. If any one of the above is higher than this utility, the above utility is ignored
  function UtilIdle(const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
  begin
    Result := 5000 + trunc(sqrt((ScreenWidth()-1440)**2 + (ScreenHeight()-900)**2)) * 3;
  end;

  procedure ActionIdle(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  begin
    AIStop(ship, rotation, thrust);
    shooting := False;
  end;

end.
