//
//Enemy Create, Move and Draw procedures
//

procedure SetupEnemy(var enemy: TShip);
begin
  enemy.kind := SK_ENEMY;
  enemy.rad := ENEMY_RADIUS_OUT;
  enemy.last := -1;
  enemy.alive := false;
  enemy.int := 0;
  enemy.shields := ENEMY_SHIELD_HIGH;
  
  //unused stuff
  SetLength(enemy.point,0);
  enemy.rot := 0;
  enemy.respawn := 0;
  enemy.thrust := false;
end;

procedure CreateEnemy(var enemy, player: TShip; var asteroids: TAsteroidArray);
begin
  SetupEnemy(enemy); //just to reinitialise him before we spawn...
  enemy.pos := OffscreenPosition(Trunc(enemy.rad));
  enemy.vel := VectorFromAngle(CalculateAngleBetween(enemy.pos,player.pos),ENEMY_ACCELERATION);
  enemy.alive := true;
end;

procedure KillEnemy(var enemy: TShip; var debris: TDebrisArray); overload;
begin
  enemy.alive := false;
  CreateDebris(enemy,debris);
end;

procedure KillEnemy(var enemy: TShip; var state: TState; var debris: TDebrisArray; var notes: TNoteArray); overload; //when state is passed in, we add the score! :D
var
  score: Integer;
begin
  score := 1000;
  state.score += score;
  CreateScore(notes,score,enemy);
  state.enemylives -= 1;

  enemy.alive := false;
  CreateDebris(enemy,debris);
end;

procedure MoveEnemy(var enemy, player: TShip; var asteroids: TAsteroidArray);
var
  i, closest: Integer;
  closestDist, curDist: Double;
begin
  closest := 0;
  closestDist := -1;
  for i := 0 to High(asteroids) do
  begin
    curDist := CalculateDistWithWrap(enemy.pos,asteroids[i].pos);
    if (closestDist < 0) or (curDist < closestDist) then
    begin
      closest := i;
      closestDist := curDist;
    end;
  end;
  
  //WriteLn('Closest Asteroid: ',closest,', Distance: ',closestDist:4:2);
  
  if closestDist < (enemy.rad + ENEMY_ASTEROIDDANGERDIST + asteroids[closest].rad) then
    enemy.vel += VectorFromAngle(CalculateAngleWithWrap(asteroids[closest].pos,enemy.pos),ENEMY_ACCELERATION)
  else if player.alive then
  begin
    if CalculateDistWithWrap(enemy.pos,player.pos) >= (enemy.rad + ENEMY_PLAYERDANGERDIST + player.rad) then
      enemy.vel += VectorFromAngle(CalculateAngleWithWrap(enemy.pos,player.pos),ENEMY_ACCELERATION)
    else
      enemy.vel -= VectorFromAngle(CalculateAngleWithWrap(enemy.pos,player.pos),ENEMY_ACCELERATION);
  end;
  enemy.vel := LimitVector(enemy.vel,ENEMY_MAXSPEED);
  
  enemy.pos += enemy.vel;
  WrapPosition(enemy.pos);
  
  if (enemy.shields < ENEMY_SHIELD_HIGH) then
    enemy.shields += 1;

  if enemy.int > 0 then
    enemy.int -= 1;
end;

procedure DrawEnemy(const enemy: TShip);
var
   shipColor: Color;
begin
  shipColor := $FFFF9900;
  if (enemy.shields < ENEMY_SHIELD_HIGH) then
    shipColor := $02020100 * Trunc((0.5 * Cosine((enemy.shields mod 20) * 180 / 10) + 0.5) * 127) + $01010000 * Trunc((0.5 * Cosine((enemy.shields mod 20) * 180 / 10 + 180) + 0.5) * 255);

  DrawCircle(shipColor,false,enemy.pos,Trunc(enemy.rad));
  DrawCircle(shipColor,false,enemy.pos,ENEMY_RADIUS_IN);
  
  if (enemy.pos.x < 0) or (enemy.pos.x > ScreenWidth()) or (enemy.pos.y < 0) or (enemy.pos.y > ScreenHeight()) then
    DrawPointer(enemy,shipColor);
end;