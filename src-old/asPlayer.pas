unit asPlayer;

interface
  uses asTypes;

  procedure CreatePlayer(var player: TShip);
  
  procedure ResetPlayer(var player: TShip; var state: TState);
  
  procedure SpawnPlayer(var player: TShip; var state: TState);
  
  procedure KillPlayer(var player: TShip; var state: TState; var debris: TDebrisArray; var notes: TNoteArray);
  
  procedure MovePlayer(var player: TShip);
  
  procedure DrawPlayer(const player: TShip);  

implementation
  uses sgCore, sgGeometry, sgInput, sgTypes, asConstants, asDraw, asEffects, asNotes, asOffscreen;
  procedure CreatePlayer(var player: TShip);
  begin
    player.kind := SK_PLAYER;
    
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
  end;

  procedure ResetPlayer(var player: TShip; var state: TState);
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
    player.thrust := false;
    
    state.lives -= 1;
  end;

  procedure SpawnPlayer(var player: TShip; var state: TState);
  begin
    ResetPlayer(player,state);
    player.respawn := PLAYER_RESPAWN_SHOW;
    state.lives += 1;
  end;

  procedure KillPlayer(var player: TShip; var state: TState; var debris: TDebrisArray; var notes: TNoteArray);
  begin
    CreateDebris(player,debris);
    player.alive := false;
    if state.lives > 0 then
    begin
      CreateNote(notes,'Life Lost',player.pos,player.vel + VectorFromAngle(270,2),ColorRed);
      player.respawn := PLAYER_RESPAWN_HIGH;
    end;
  end;

  procedure MovePlayer(var player: TShip);
  begin
    if KeyDown(VK_LEFT) and not KeyDown(VK_RIGHT) then
      player.rot -= 5
    else if KeyDown(VK_RIGHT) and not KeyDown(VK_LEFT) then
      player.rot += 5;
    
    if player.rot < 0 then
      player.rot += 360
    else if player.rot > 360 then
      player.rot -= 360;
    
    if KeyDown(VK_UP) then
    begin
      player.vel += VectorFromAngle(player.rot,PLAYER_ACCELERATION);
      player.thrust := not player.thrust;
    end;

    if sqrt(sqr(player.vel.x) + sqr(player.vel.y)) < MAX_SPEED then
      player.vel := LimitVector(player.vel,MAX_SPEED);

    player.pos += player.vel;
    WrapPosition(player.pos);
      
    if (player.shields < PLAYER_SHIELD_HIGH) then
      player.shields += 1;
      
    if player.int > 0 then
      player.int -= 1;
  end;

  procedure DrawPlayer(const player: TShip);
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

    DrawShape(PlayerShip(),player.pos,player.rot,shipColor);

    if KeyDown(VK_UP) and player.thrust then
    begin
      thrusterPoints := Copy(PlayerShip(),1,3);
      thrusterPoints[1].x -= PLAYER_THRUST_AMPLITUDE;
      DrawShape(thrusterPoints,player.pos,player.rot,thrustColor,false);
    end;

    //if the player is offscreen...
    if (player.pos.x < 0) or (player.pos.x > ScreenWidth()) or (player.pos.y < 0) or (player.pos.y > ScreenHeight()) then
      DrawPointer(player,shipColor);
  end;

end.