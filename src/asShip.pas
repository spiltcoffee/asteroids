unit asShip;

interface
  uses sgTypes, asTypes;

  procedure CreateShip(var player: TShip);

  procedure ResetShip(var player: TShip; var state: TState);

  procedure SpawnShip(var player: TShip; var state: TState);

  procedure KillShip(var player: TShip; var state: TState; var debris: TDebrisArray; var notes: TNoteArray);

  procedure MoveShip(var ship: TShip; const state: TState);

  procedure DrawShip(const player: TShip);

implementation
  uses sgCore, sgGeometry, sgInput, asAudio, asConstants, asDraw, sgGraphics, asEffects, asNotes, asOffscreen, asShipController;

  procedure CreateShip(var player: TShip);
  begin
    player.kind := SK_SHIP_AI;

    player.rad := 9;

    player.pos.x := ScreenWidth() / 2;
    player.pos.y := ScreenHeight() / 2;

    player.rot := 270;

    player.vel.x := 0;
    player.vel.y := 0;

    player.last := -1;
    player.alive := false;
    player.shields := PLAYER_SHIELD_HIGH;
    player.respawn := 0;
    player.int := 0;
    player.thrust := false;
    player.controller.move_state := smAlign;
    player.controller.state := ssMove;
  end;

  procedure ResetShip(var player: TShip; var state: TState);
  begin
    player.pos.x := ScreenWidth() / 2;
    player.pos.y := ScreenHeight() / 2;

    player.rot := 270;

    player.vel.x := 0;
    player.vel.y := 0;

    player.last := -1;
    player.alive := true;
    player.shields := PLAYER_SHIELD_HIGH;
    player.int := 0;
    player.thrust := False;

    state.lives -= 1;
  end;

  procedure SpawnShip(var player: TShip; var state: TState);
  begin
    ResetShip(player,state);
    player.respawn := PLAYER_RESPAWN_SHOW;
    state.lives += 1;
  end;

  procedure KillShip(var player: TShip; var state: TState; var debris: TDebrisArray; var notes: TNoteArray);
  begin
    CreateDebris(player,debris);
    player.alive := false;
    EndThrusterEffect();
    if state.lives > 0 then
    begin
      CreateNote(notes,'Life Lost',player.pos,player.vel + VectorFromAngle(270,2),ColorRed);
      player.respawn := PLAYER_RESPAWN_HIGH;
    end;
  end;

  procedure MoveShip(var ship: TShip; const state: TState);
  var
    thrust: Boolean;
    rotation: Double;
  begin
    thrust := False;
    rotation := 0;
    if ship.kind = SK_SHIP_PLAYER then
      MovePlayer(ship, state, rotation, thrust)
    else
      ShipAI(ship, rotation, thrust);

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
    shipColor, thrustColor: Color;
  begin
    shipColor := ColorGreen;
    thrustColor := ColorBlue;
    if (player.respawn > 0) then
    begin
      shipColor += $01000000 * Trunc((0.4 * Cosine((player.respawn mod 20) * 180 / 10) + 0.6) * 255);
      thrustColor += $01000000 * Trunc((0.4 * Cosine((player.respawn mod 20) * 180 / 10) + 0.6) * 255);
    end
    else if (player.shields < PLAYER_SHIELD_HIGH) then
      shipColor := $01000100 * Trunc((0.5 * Cosine((player.shields mod 20) * 180 / 10) + 0.5) * 255) + $01010000 * Trunc((0.5 * Cosine((player.shields mod 20) * 180 / 10 + 180) + 0.5) * 255);

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
