unit asCollisions;

interface
  uses sgTypes, asTypes;
  
  function PreviouslyCollided(ignoreCollision: TCollisionArray; i, j: Integer): Boolean;
  
  function ImpreciseCheck(var asteroid1: TAsteroid; var asteroid2: TAsteroid): Boolean;
  function PreciseCheck(var asteroid1: TAsteroid; var asteroid2: TAsteroid): Boolean;
  
  procedure ShakeScreen();
  
  procedure Collide(var asteroid1: TAsteroid; var asteroid2: TAsteroid); overload;
  procedure Collide(var asteroid: TAsteroid; var ship: TShip); overload;
  procedure Collide(var ship1, ship2: TShip); overload;
  
  function FindCollisionPoint(const center1: Point2D; const radius1: Double; const center2: Point2D; const radius2: Double): Point2D;

implementation
  uses sgCamera, sgCore, sgGeometry, asConstants;

  function PreviouslyCollided(ignoreCollision: TCollisionArray; i, j: Integer): Boolean;
  var
    cur: Integer;
  begin
    result := false;
    for cur := 0 to High(ignoreCollision) do begin
      if ((ignoreCollision[cur].i = i) and (ignoreCollision[cur].j = j)) or
         ((ignoreCollision[cur].i = j) and (ignoreCollision[cur].j = i)) then
      begin
        result := true;
        Break;
      end;
    end;
  end;
  
  function ImpreciseCheck(var asteroid1: TAsteroid; var asteroid2: TAsteroid): Boolean;
  begin
    result := PointPointDistance(asteroid1.pos, asteroid2.pos) <= (asteroid1.rad + asteroid2.rad);
  end;
  
  function PreciseCheck(var asteroid1: TAsteroid; var asteroid2: TAsteroid): Boolean;
  var
    i, j: Integer;
    line: LineSegment;
  begin
    result := false;
    for i := 0 to High(asteroid1.point) - 1 do begin
      line := LineFrom(asteroid1.pos + asteroid1.point[i], asteroid1.pos + asteroid1.point[i + 1]);
      for j := 0 to High(asteroid2.point) - 1 do begin
        if LineSegmentsIntersect(line, LineFrom(asteroid2.pos + asteroid2.point[j], asteroid2.pos + asteroid2.point[j + 1])) then begin
          result := true;
          Break;
        end;
      end;
    end;
  end;
  
  procedure ShakeScreen();
  begin
    SetCameraX(SHAKE_FACTOR + Rnd(3) - 1);
    SetCameraY(SHAKE_FACTOR + Rnd(3) - 1);
  end;

  function GetCollisionObject(const asteroid: TAsteroid): CollisionObject; overload;
  begin
    result.pos := asteroid.pos;
    result.vel := asteroid.vel;
    result.rotspeed := 0;
    result.mass := sqr(asteroid.rad) * PI * ASTEROID_DENSITY;
    result.damage := 0;
  end;

  function GetCollisionObject(const ship: TShip): CollisionObject; overload;
  begin
    result.pos := ship.pos;
    result.vel := ship.vel;
    result.rotspeed := 0;
    if ship.kind = SK_PLAYER then
      result.mass := PLAYER_MASS
    else
      result.mass := ENEMY_MASS;
    result.damage := 0;
  end;

  procedure CalculateCollision(var object1, object2: CollisionObject); //velocity and rotspeed are changed at the end, use GetCollisionObject to form proper record
  var
    normal, tangent, proja1norm, proja2norm, proja1tan, proja2tan, Vector1, Vector2: Vector;
    mag1, mag2: Double;
  begin
    mag1 := sqrt(sqr((object1.mass - object2.mass) / (object1.mass + object2.mass) * object1.vel.x + (2 * object2.mass) / (object1.mass + object2.mass) * object2.vel.x) + sqr((object1.mass - object2.mass) / (object1.mass + object2.mass) * object1.vel.y + (2 * object2.mass) / (object1.mass + object2.mass) * object2.vel.y));
    mag2 := sqrt(sqr((object2.mass - object1.mass) / (object1.mass + object2.mass) * object2.vel.x + (2 * object1.mass) / (object1.mass + object2.mass) * object1.vel.x) + sqr((object2.mass - object1.mass) / (object1.mass + object2.mass) * object2.vel.y + (2 * object1.mass) / (object1.mass + object2.mass) * object1.vel.y));

    normal := UnitVector(VectorFromPoints(object1.pos,object2.pos));
    tangent := VectorNormal(normal);

    proja1norm.x := DotProduct(object1.vel,normal) * normal.x;
    proja1norm.y := DotProduct(object1.vel,normal) * normal.y;

    proja2norm.x := DotProduct(object2.vel,normal) * normal.x;
    proja2norm.y := DotProduct(object2.vel,normal) * normal.y;

    proja1tan.x := DotProduct(object1.vel,tangent) * tangent.x;
    proja1tan.y := DotProduct(object1.vel,tangent) * tangent.y;

    proja2tan.x := DotProduct(object2.vel,tangent) * tangent.x;
    proja2tan.y := DotProduct(object2.vel,tangent) * tangent.y;

    Vector1 := proja2norm + proja1tan;
    Vector2 := proja1norm + proja2tan;

    object1.rotspeed := CalculateAngle(InvertVector(object1.vel),Vector1);
    if object1.rotspeed < -180 then
      object1.rotspeed += 360
    else if object1.rotspeed > 180 then
      object1.rotspeed -= 360;
    object1.rotspeed /= (360000);

    object2.rotspeed := CalculateAngle(InvertVector(object2.vel),Vector2);
    if object2.rotspeed < -180 then
      object2.rotspeed += 360
    else if object2.rotspeed > 180 then
      object2.rotspeed -= 360;
    object2.rotspeed /= (360000);
    
    object1.damage := Trunc(VectorMagnitude(object2.vel - object1.vel) * (object2.mass / (object1.mass + object2.mass)) * COLLISION_MODIFIER);
    object2.damage := Trunc(VectorMagnitude(object1.vel - object2.vel) * (object1.mass / (object1.mass + object2.mass)) * COLLISION_MODIFIER);

    object1.vel := VectorFromAngle(VectorAngle(Vector1),mag1);
    object2.vel := VectorFromAngle(VectorAngle(Vector2),mag2);
  end;

  procedure Collide(var asteroid1: TAsteroid; var asteroid2: TAsteroid); overload;
  var
    object1, object2: CollisionObject;
  begin
    object1 := GetCollisionObject(asteroid1);
    object2 := GetCollisionObject(asteroid2);

    CalculateCollision(object1,object2);

    asteroid1.vel := object1.vel;
    asteroid1.rot.speed -= object1.rotspeed;

    asteroid2.vel := object2.vel;
    asteroid2.rot.speed -= object2.rotspeed;
  end;

  procedure Collide(var asteroid: TAsteroid; var ship: TShip); overload;
  var
    object1, object2: CollisionObject;
  begin
    object1 := GetCollisionObject(asteroid);
    object2 := GetCollisionObject(ship);

    CalculateCollision(object1,object2);

    asteroid.vel := object1.vel;
    asteroid.rot.speed -= object1.rotspeed;

    if ship.respawn = 0 then
      ship.shields -= object2.damage;  
    if ship.shields > 0 then
      ship.vel := object2.vel;
      
    if ship.kind = SK_PLAYER then
      ShakeScreen();
  end;

  procedure Collide(var ship1, ship2: TShip); overload;
  var
    object1, object2: CollisionObject;
  begin
    object1 := GetCollisionObject(ship1);
    object2 := GetCollisionObject(ship2);

    CalculateCollision(object1,object2);
    
    if ship1.respawn = 0 then
      ship1.shields -= object1.damage;
    if ship1.shields > 0 then
      ship1.vel := object1.vel;

    if ship2.respawn = 0 then
      ship2.shields -= object2.damage;
    if ship2.shields > 0 then
      ship2.vel := object2.vel;
    
    if ship1.kind <> ship2.kind then
      ShakeScreen();
  end;

  function FindCollisionPoint(const center1: Point2D; const radius1: Double; const center2: Point2D; const radius2: Double): Point2D;
  begin
    if center1.x < center2.x then
      result.x := center1.x + (center2.x - center1.x) / (radius1 + radius2) * radius1
    else
      result.x := center2.x + (center1.x - center2.x) / (radius1 + radius2) * radius2;
    
    if center1.y < center2.y then
      result.y := center1.y + (center2.y - center1.y) / (radius1 + radius2) * radius1
    else
      result.y := center2.y + (center1.y - center2.y) / (radius1 + radius2) * radius2;
  end;

end.