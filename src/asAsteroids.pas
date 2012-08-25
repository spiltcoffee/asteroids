unit asAsteroids;

interface
  uses sgTypes, asTypes;
  
  procedure CreateAsteroid(var asteroids: TAsteroidArray; const player: TShip; offscreen: Boolean = false);

  procedure DestroyAsteroid(var asteroids: TAsteroidArray; const del: Integer; const collision: Point2D; var debris: TDebrisArray); overload;
  procedure DestroyAsteroid(var asteroids: TAsteroidArray; const del: Integer; const collision: Point2D; var state: TState; var debris: TDebrisArray; var notes: TNoteArray); overload;
  procedure DestroyTwoAsteroids(var asteroids: TAsteroidArray; const del1: Integer; const del2: Integer; const collision: Point2D; var debris: TDebrisArray);
  
  procedure MoveAsteroid(var asteroid: TAsteroid);
  
  procedure DrawAsteroid(asteroid: TAsteroid);
  
implementation
  uses sgCore, sgGeometry, asConstants, asDraw, asEffects, asExtras, asNotes, asOffscreen, asState, Math;

  function GenerateAsteroid(maxsize: Integer = -1): TAsteroid;
  var
    i, maxpoints: Integer;
    amplitude, offset: Double;
  begin
    if maxsize > -1 then
      result.maxsize := maxsize
    else
      result.maxsize := Round(Rnd(ASTEROID_MAXSIZE - ASTEROID_MINSIZE)) + ASTEROID_MINSIZE;

    result.rad := 0;
    maxpoints := Rnd(ASTEROID_MAXPOINTS - ASTEROID_MINPOINTS + 1) + ASTEROID_MINPOINTS;
    SetLength(result.point,maxpoints);
    for i := 0 to (maxpoints - 1) do
    begin
      amplitude := Rnd(Round(result.maxsize / 2) + 1) + Round(result.maxsize / 2);
      offset := Rnd() / (maxpoints / 6);
      result.point[i].x := Trunc(amplitude * Cosine((i / Length(result.point)) * 360 + offset));
      result.point[i].y := Trunc(amplitude * Sine((i / Length(result.point)) * 360 + offset));
      result.rad := Max(result.rad, amplitude);
    end;
    
    result.vel := VectorFromAngle(Rnd(180),(Rnd() - 0.5) * ASTEROID_SPEED_MULTIPLIER);
    
    result.rot.angle := 0;
    result.rot.speed := (Rnd() - 1 / 2) * 2 * ASTEROID_MAXROTATION;
    result.last := -1;
  end;

  procedure CreateAsteroid(var asteroids: TAsteroidArray; const player: TShip; offscreen: Boolean = false);
  var
    new, attempts: Integer;
  begin
    SetLength(asteroids,Length(asteroids) + 1);
    new := High(asteroids);
    asteroids[new] := GenerateAsteroid();
    
    attempts := ASTEROID_MAXCREATION;
    repeat
      attempts -= 1;
      if offscreen then
        asteroids[new].pos := OffscreenPosition(asteroids[new].maxsize + ASTEROID_MINSIZE)
      else
      begin
        asteroids[new].pos.x := Rnd(ScreenWidth());
        asteroids[new].pos.y := Rnd(ScreenHeight());
      end;
    until (ProximityCheck(asteroids[new].pos,player.pos,ASTEROID_MINDISTFROMPLAYER) and CheckIfSpaceEmpty(asteroids,new)) or (attempts = 0);
  end;

  procedure DestroyAsteroid(var asteroids: TAsteroidArray; const del: Integer; const collision: Point2D; var debris: TDebrisArray); overload;
  var
    new, maxsize: Integer;
    direction: Integer;
    normal: Vector;
  begin
    if (asteroids[del].rad / 2) > ASTEROID_MINSIZE then
    begin
      maxsize := Trunc(asteroids[del].rad / 2); // to adjust it for random dot selection
      direction := -1;
      normal := VectorNormal(VectorTo(collision.x - asteroids[del].pos.x, collision.y - asteroids[del].pos.y));
      repeat
        direction *= -1;
        SetLength(asteroids,Length(asteroids) + 1);
        new := High(asteroids);
        asteroids[new] := GenerateAsteroid(maxsize);
        asteroids[new].pos := asteroids[del].pos + normal * asteroids[new].rad * direction;
        asteroids[new].vel := asteroids[del].vel + normal * (Rnd() / 0.5) * direction;
      until direction < 0;
    end;
    CreateDebris(asteroids[del],debris);
    Remove(asteroids,del);
  end;

  procedure DestroyAsteroid(var asteroids: TAsteroidArray; const del: Integer; const collision: Point2D; var state: TState; var debris: TDebrisArray; var notes: TNoteArray); overload;
  var
    score: Integer;
  begin
    score := Trunc(sqr(ASTEROID_MAXSIZE - asteroids[del].rad) * PI);
    score := Max((score - (score mod 100)) div 10, ASTEROID_MINSCORE);
    state.score += score;
    CreateScore(notes,score,asteroids[del]);

    DestroyAsteroid(asteroids,del,collision,debris);
  end;
  
  //Destroy the asteroid that's further in the array first to prevent the other from shifting position.
  //I'm lazy, what's new?
  procedure DestroyTwoAsteroids(var asteroids: TAsteroidArray; const del1: Integer; const del2: Integer; const collision: Point2D; var debris: TDebrisArray);
  begin
    DestroyAsteroid(asteroids, Max(del1, del2), collision, debris);
    DestroyAsteroid(asteroids, Min(del1, del2), collision, debris);
  end;

  procedure MoveAsteroid(var asteroid: TAsteroid);
  begin
    if sqrt(sqr(asteroid.vel.x) + sqr(asteroid.vel.y)) > MAX_SPEED then
      asteroid.vel := LimitVector(asteroid.vel,MAX_SPEED);

    asteroid.pos += asteroid.vel;
    WrapPosition(asteroid.pos);

    if asteroid.rot.speed > MAX_ROTATION then
      asteroid.rot.speed := MAX_ROTATION
    else if asteroid.rot.speed < -MAX_ROTATION then
      asteroid.rot.speed := -MAX_ROTATION;
    
    asteroid.rot.angle += asteroid.rot.speed;
    if asteroid.rot.angle < 0 then
      asteroid.rot.angle += 360
    else if asteroid.rot.angle > 360 then
      asteroid.rot.angle -= 360;
  end;

  procedure DrawAsteroid(asteroid: TAsteroid);
  begin
    DrawShape(asteroid.point,asteroid.pos,asteroid.rot.angle,ColorRed);
  end;

end.