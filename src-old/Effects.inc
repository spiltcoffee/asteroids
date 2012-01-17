//
//Effects (bullets, debris) Create, Move and Draw procedures
//

procedure CreateBullet(var bullets: TBulletArray; const shooter, target: TShip);
var
  new, time: Integer;
  angle: Double;
  point: Point2DArray;
begin
  if shooter.kind = SK_PLAYER then
  begin
    SetLength(bullets,Length(bullets) + 1);
    new := High(bullets);

    point := CopyRotateTranslate(PlayerShip(true),shooter.pos,shooter.rot);
    
    bullets[new].pos := point[0]; //rotate, then translate
    bullets[new].vel := shooter.vel + VectorFromAngle(shooter.rot,BULLET_SPEED);
    bullets[new].life := BULLET_START;
    bullets[new].kind := SK_PLAYER;
  end
  else if shooter.kind = SK_ENEMY then
  begin
    time := BULLET_START + 1;
    repeat
      time -= 1;
    until not PointInCircle(target.pos + target.vel * time,CircleAt(shooter.pos + shooter.vel * time,Trunc(BULLET_SPEED * time + shooter.rad)));
    time += 1;
    if time <= BULLET_START then
    begin
      SetLength(bullets,Length(bullets) + 1);
      new := High(bullets);

      angle := CalculateAngleWithWrap(shooter.pos + shooter.vel * time,target.pos + target.vel * time);
    
      bullets[new].pos := shooter.pos + VectorFromAngle(angle,shooter.rad);
      bullets[new].vel := shooter.vel + VectorFromAngle(angle,BULLET_SPEED);
      bullets[new].life := BULLET_START;
      bullets[new].kind := SK_ENEMY;
    end;
  end;
end;

procedure CreateSparks(var debris: TDebrisArray; amount: Integer; pos: Point2D); //sparks are now a special kind of debris that we can create, but now use the debris record
var
  i, new: Integer;
begin
  for i := 1 to amount do
  begin
    SetLength(debris,Length(debris) + 1);
    new := High(debris);
    debris[new].kind := Spark;
    debris[new].pos := pos;
    debris[new].vel := VectorFromAngle(Rnd(360),SPARK_AVG_SPEED + Rnd(SPARK_AVG_SPEED));
    SetLength(debris[new].point,2);
    debris[new].point[0].x := 0;
    debris[new].point[0].y := 0;
    debris[new].point[1] := debris[new].vel * SPARK_POINT_MODIFIER;
    debris[new].rot.speed := 0;
    debris[new].rot.angle := 0;
    debris[new].life := SPARK_START;
    debris[new].col := ColorYellow;
  end;
end;

procedure CreateDebris(const asteroid: TAsteroid; var debris: TDebrisArray); overload;
var
  i, new: Integer;
  nextPoint: Point2D;
  drawingPoints: Point2DArray;
begin
  drawingPoints := CopyRotateTranslate(asteroid.point,asteroid.pos,asteroid.rot.angle);

  for i := 0 to High(drawingPoints) do
  begin
    SetLength(debris,Length(debris) + 1);
    new := High(debris);

    if i < High(drawingPoints) then
      nextPoint := drawingPoints[i + 1]
    else 
      nextPoint := drawingPoints[0];

    debris[new].pos := LineMidPoint(drawingPoints[i],nextPoint);

    SetLength(debris[new].point,2);
    debris[new].point[0] := drawingPoints[i] - debris[new].pos;
    debris[new].point[1] := nextPoint - debris[new].pos;

    debris[new].rot.angle := 0;
    debris[new].rot.speed := asteroid.rot.speed + (Rnd() - 0.5) * 2 * DEBRIS_MAXROTATION;

    debris[new].vel := asteroid.vel + VectorFromAngle(CalculateAngleBetween(asteroid.pos,debris[new].pos),DEBRIS_SPEED_MODIFIER * (Rnd() - 0.5));

    debris[new].life := DEBRIS_START;
    debris[new].kind := Line;
    debris[new].col := ColorRed;
  end;
end;

procedure CreateDebris(const ship: TShip; var debris: TDebrisArray); overload;
var
  i, new: Integer;
  nextPoint: Point2D;
  drawingPoints: Point2DArray;
begin
  if ship.kind = SK_PLAYER then
  begin
    drawingPoints := CopyRotateTranslate(PlayerShip(),ship.pos,ship.rot); //so we don't modify the original array of points

    for i := 0 to High(drawingPoints) do
    begin
      SetLength(debris,Length(debris) + 1);
      new := High(debris);

      if i < High(drawingPoints) then
        nextPoint := drawingPoints[i + 1]
      else 
        nextPoint := drawingPoints[0];

      debris[new].pos := LineMidPoint(drawingPoints[i],nextPoint);

      SetLength(debris[new].point,2);
      debris[new].point[0] := drawingPoints[i] - debris[new].pos;
      debris[new].point[1] := nextPoint - debris[new].pos;

      debris[new].rot.angle := 0;
      debris[new].rot.speed := (Rnd() - 0.5) * 2 * DEBRIS_MAXROTATION;

      debris[new].vel := ship.vel + VectorFromAngle(CalculateAngleBetween(ship.pos,debris[new].pos),DEBRIS_SPEED_MODIFIER * (Rnd() - 0.5));
  
      debris[new].life := DEBRIS_START;
      debris[new].kind := Line;
      debris[new].col := ColorGreen;
    end;
  end
  else if ship.kind = SK_ENEMY then
  begin
    for i := 1 to 2 do
    begin
      SetLength(debris,Length(debris) + 1);
      new := High(debris);
      SetLength(debris[new].point,1);
      debris[new].point[0].y := 0;
      if i = 1 then
        debris[new].point[0].x := ENEMY_RADIUS_OUT
      else
        debris[new].point[0].x := ENEMY_RADIUS_IN;

      debris[new].pos := ship.pos;
      debris[new].rot.angle := 0;
      debris[new].rot.speed := 0;

      debris[new].vel := ship.vel + VectorFromAngle(Rnd(360),DEBRIS_SPEED_MODIFIER * (Rnd() - 0.5));// * Cosine(CalculateAngle(player.pos.x,player.pos.y,debris[new].pos.x,debris[new].pos.y));
      //debris[new].vel.y := player.vel.y + DEBRIS_SPEED_MODIFIER * (Rnd() - 0.5) * Sine(CalculateAngle(player.pos.x,player.pos.y,debris[new].pos.x,debris[new].pos.y));
      
      debris[new].life := DEBRIS_START;
      debris[new].kind := Circle;
      debris[new].col := $FFFF9900;
    end;
  end;
end;

procedure MoveBullet(var bullet: TBullet);
begin
  bullet.pos += bullet.vel;
  WrapPosition(bullet.pos);
  
  bullet.life -= 1;
end;

procedure MoveDebris(var debris: TDebris);
begin
  if debris.kind = Spark then
  begin
    debris.vel := LimitVector(debris.vel,VectorMagnitude(debris.vel) * SPARK_ACCELERATION);
    debris.point[1] := debris.vel * SPARK_POINT_MODIFIER;
  end;
  debris.pos += debris.vel;
  WrapPosition(debris.pos);
  
  debris.rot.angle += debris.rot.speed;
  if debris.rot.angle < 0 then
    debris.rot.angle += 360
  else if debris.rot.angle > 360 then
    debris.rot.angle -= 360;
  
  debris.life -= 1;
end;

procedure DrawBullet(const bullet: TBullet);
begin
  if bullet.life > BULLET_END then
    DrawCircle(ColorWhite + ($01000000 * Trunc((bullet.life - BULLET_END) / (BULLET_START - BULLET_END) * 255)),false,bullet.pos.x,bullet.pos.y,BULLET_RADIUS);
end;

procedure DrawDebris(const debris: TDebris);
begin
  if debris.life > 0 then
  begin
    if debris.kind = Line then
      DrawShape(debris.point,debris.pos,debris.rot.angle,debris.col + ($01000000 * Trunc((debris.life / DEBRIS_START) * 255)),false)
    else if debris.kind = Spark then
      DrawShape(debris.point,debris.pos,debris.rot.angle,debris.col + ($01000000 * Trunc((debris.life / SPARK_START) * 255)),false)
    else
      DrawCircle(debris.col + ($01000000 * Trunc((debris.life / DEBRIS_START) * 255)),false,debris.pos,Trunc(debris.point[0].x));
  end;
end;