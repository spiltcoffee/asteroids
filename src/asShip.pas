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

unit asShip;

interface
  uses sgTypes, asTypes;

  procedure CreateShip(var ship: TShip; const kind: TShipKind = sk1ShipPlayer);

  procedure ResetShip(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip);

  procedure SpawnShip(var ship: TShip; var debris: TDebrisArray; const asteroids: TAsteroidArray; const enemy: TShip);

  procedure KillShip(var ship: TShip; var debris: TDebrisArray);

  procedure MoveShip(var ship: TShip; const state: TState; const asteroids: TAsteroidArray; const enemy: TShip);

  procedure DrawShip(const player: TShip);

implementation
  uses sgCore, sgGeometry, sgInput, asAudio, asConstants, asDraw, sgGraphics, asEffects, asNotes, asOffscreen, asShipController, asPath, math;

  procedure CreateShip(var ship: TShip; const kind: TShipKind = sk1ShipPlayer);
  begin
    ship.kind := kind;

    ship.rad := 9;

    if ship.kind = sk2ShipAI then begin
      ship.pos.x := ScreenWidth() * (3 / 4);
      ship.color := ColorBlue;
    end
    else begin
      ship.pos.x := ScreenWidth() / 4;
      ship.color := ColorGreen;
    end;

    ship.pos.y := ScreenHeight() / 2;

    ship.rot := 270;

    ship.vel.x := 0;
    ship.vel.y := 0;

    ship.last := -1;
    ship.alive := false;
    ship.shields := PLAYER_SHIELD_HIGH;
    ship.respawn := 0;
    ship.int := 0;
    ship.thrust := false;
    ship.kills := 0;
    ship.deaths := 0;

    ship.controller.move_state := smAlign;
    ship.controller.arrive_state := ssMove;
    ship.controller.pathfind_timeout := 0;
    ship.controller.action := saIdle;
    ship.controller.gob_timeout := 0;
    ship.controller.target.x := 0;
    ship.controller.target.y := 0;
  end;

  procedure ResetShip(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip);
  var
    random_point: Point2D;
  begin
    repeat
      random_point.x := random(ScreenWidth());
      random_point.y := random(ScreenHeight());
    until CheckIfSpaceEmpty(random_point, ship.rad, asteroids, enemy);
    ship.pos := random_point;

    ship.rot := 270;

    ship.vel.x := 0;
    ship.vel.y := 0;

    ship.last := -1;
    ship.alive := true;
    ship.shields := PLAYER_SHIELD_HIGH;
    ship.int := 0;
    ship.thrust := False;
    ship.path := CreateEmptyPath;

    ship.controller.move_state := smAlign;
    ship.controller.arrive_state := ssMove;
    ship.controller.pathfind_timeout := 0;
    ship.controller.action := saIdle;
    ship.controller.gob_timeout := 0;
    ship.controller.target.x := 0;
    ship.controller.target.y := 0;
  end;

  procedure SpawnShip(var ship: TShip; var debris: TDebrisArray; const asteroids: TAsteroidArray; const enemy: TShip);
  begin
    ResetShip(ship, asteroids, enemy);
    ship.respawn := PLAYER_RESPAWN_SHOW;
    CreateSpawnDebris(ship, debris);
  end;

  procedure KillShip(var ship: TShip; var debris: TDebrisArray);
  begin
    CreateDebris(ship, debris);
    ship.alive := false;
    EndThrusterEffect();
    ship.deaths += 1;
  end;

  procedure MoveShip(var ship: TShip; const state: TState; const asteroids: TAsteroidArray; const enemy: TShip);
  var
    thrust: Boolean;
    rotation: Double;
    shooting: Boolean;
  begin
    thrust := False;
    rotation := 0;
    if ship.kind = sk1ShipPlayer then
      ShipPlayer(ship, state, rotation, thrust, shooting)
    else
      ShipAI(ship, asteroids, enemy, state.map, rotation, thrust, shooting);

    ship.shooting := shooting;

    ship.rot += rotation * PLAYER_ROTATION_SPEED;

    if ship.rot < 0 then
      ship.rot += 360
    else if ship.rot > 360 then
      ship.rot -= 360;

    if thrust = True then begin
      StartThrusterEffect(state);
      ship.vel += VectorFromAngle(ship.rot,PLAYER_ACCELERATION);
      ship.thrust := not ship.thrust;
    end
    else begin
      EndThrusterEffect();
      ship.thrust := False;
    end;

    if sqrt(sqr(ship.vel.x) + sqr(ship.vel.y)) < MAX_SPEED then
      ship.vel := LimitVector(ship.vel,MAX_SPEED);

    ship.pos += ship.vel;
    WrapPosition(ship.pos);

    if (ship.shields < PLAYER_SHIELD_HIGH) then
      ship.shields += 1;

    if ship.int > 0 then
      ship.int -= 1;
  end;

  procedure DrawShip(const player: TShip);
  var
    thrusterPoints: Point2DArray;
    shipColor, shipHurtColor, thrustColor: Color;
  begin
    shipColor := player.color;
    shipHurtColor := $01010101 and shipColor;

    thrustColor := ColorRed;
    if (player.respawn > 0) then
    begin
      shipColor += $01000000 * Trunc((0.4 * Cosine((player.respawn mod 20) * 180 / 10) + 0.6) * 255);
      thrustColor += $01000000 * Trunc((0.4 * Cosine((player.respawn mod 20) * 180 / 10) + 0.6) * 255);
    end
    else if (player.shields < PLAYER_SHIELD_HIGH) then
      shipColor := shipHurtColor * Trunc((0.5 * Cosine((player.shields mod 20) * 180 / 10) + 0.5) * 255) + $01010000 * Trunc((0.5 * Cosine((player.shields mod 20) * 180 / 10 + 180) + 0.5) * 255);

    DrawShape(ShipPoints,player.pos,player.rot,shipColor);

    if player.thrust then
    begin
      thrusterPoints := Copy(ShipPoints,1,3);
      thrusterPoints[1].x -= PLAYER_THRUST_AMPLITUDE;
      DrawShape(thrusterPoints,player.pos,player.rot,thrustColor,false);
    end;

    //if the player is offscreen...
    if (player.pos.x < 0) or (player.pos.x > ScreenWidth()) or (player.pos.y < 0) or (player.pos.y > ScreenHeight()) then
      DrawPointer(player,shipColor);
  end;

end.
